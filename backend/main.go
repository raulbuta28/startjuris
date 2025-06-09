package main

import (
	"container/list"
	"encoding/json"
	"fmt"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/gorilla/websocket"
	"io/ioutil"
	"net/http"
	"os"
	"path/filepath"
	"strings"
	"sync"
	"time"
)

func dirExists(p string) bool {
	info, err := os.Stat(p)
	return err == nil && info.IsDir()
}

// detectRepoRoot attempts to locate the project root directory by walking
// upwards from the working directory and executable location until both
// "backend" and "dashbord-react" folders are found.
func detectRepoRoot() string {
	if wd, err := os.Getwd(); err == nil {
		dir := wd
		for i := 0; i < 5; i++ {
			if dirExists(filepath.Join(dir, "backend")) && dirExists(filepath.Join(dir, "dashbord-react")) {
				return dir
			}
			parent := filepath.Dir(dir)
			if parent == dir {
				break
			}
			dir = parent
		}
	}

	if exe, err := os.Executable(); err == nil {
		dir := filepath.Dir(exe)
		for i := 0; i < 5; i++ {
			if dirExists(filepath.Join(dir, "backend")) && dirExists(filepath.Join(dir, "dashbord-react")) {
				return dir
			}
			parent := filepath.Dir(dir)
			if parent == dir {
				break
			}
			dir = parent
		}
	}

	return "."
}

var rootDir = detectRepoRoot()

type User struct {
	ID        string   `json:"id"`
	Username  string   `json:"username"`
	Email     string   `json:"email"`
	Password  string   `json:"password"`
	Bio       string   `json:"bio,omitempty"`
	AvatarURL string   `json:"avatarUrl,omitempty"`
	Phone     string   `json:"phone,omitempty"`
	Followers []string `json:"followers,omitempty"`
	Following []string `json:"following,omitempty"`
}

var users = make(map[string]User)
var tokens = make(map[string]string) // token -> username

var tokensFile = filepath.Join(rootDir, "backend", "tokens.json")

func loadTokens() {
	data, err := os.ReadFile(tokensFile)
	if err != nil {
		return
	}
	_ = json.Unmarshal(data, &tokens)
}

func saveTokens() {
	data, err := json.MarshalIndent(tokens, "", "  ")
	if err != nil {
		return
	}
	_ = os.WriteFile(tokensFile, data, 0644)
}

var mu sync.Mutex
var userUtils = make(map[string]map[string]interface{})

type ArticlePrefs struct {
	Likes     []string `json:"likes"`
	Favorites []string `json:"favorites"`
	Saved     []string `json:"saved"`
}

var userArticlePrefs = make(map[string]*ArticlePrefs)
var userArticlePrefsFile = filepath.Join(rootDir, "backend", "user_articles.json")

func loadArticlePrefs() {
	data, err := os.ReadFile(userArticlePrefsFile)
	if err != nil {
		return
	}
	_ = json.Unmarshal(data, &userArticlePrefs)
}

func saveArticlePrefs() {
	data, err := json.MarshalIndent(userArticlePrefs, "", "  ")
	if err != nil {
		return
	}
	_ = os.WriteFile(userArticlePrefsFile, data, 0644)
}

var userFile = filepath.Join(rootDir, "backend", "users.json")

func loadUsers() {
	data, err := os.ReadFile(userFile)
	if err != nil {
		return
	}
	_ = json.Unmarshal(data, &users)
}

func saveUsers() {
	data, err := json.MarshalIndent(users, "", "  ")
	if err != nil {
		return
	}
	_ = os.WriteFile(userFile, data, 0644)
}

type Message struct {
	ID             string    `json:"id"`
	ConversationID string    `json:"conversationId"`
	SenderID       string    `json:"senderId"`
	RecipientID    string    `json:"recipientId"`
	Text           string    `json:"text"`
	Timestamp      time.Time `json:"timestamp"`
	IsRead         bool      `json:"isRead"`
	IsDelivered    bool      `json:"isDelivered"`
}

type Conversation struct {
	ID           string         `json:"id"`
	Participants []string       `json:"participants"`
	Messages     []Message      `json:"messages"`
	LastActivity time.Time      `json:"lastActivity"`
	UnreadCount  map[string]int `json:"unreadCount"`
}

var conversations = make(map[string]*Conversation)
var userConversations = make(map[string][]*Conversation)
var wsClients = make(map[string]*websocket.Conn)

// mapping of available code text files
var codeFiles = map[string]struct {
	path  string
	title string
}{
	"civil":      {path: filepath.Join(codesTextDir, "codulcivil.txt"), title: "Codul Civil"},
	"penal":      {path: filepath.Join(codesTextDir, "codulpenal.txt"), title: "Codul Penal"},
	"proc_civil": {path: filepath.Join(codesTextDir, "coduldeproceduracivila.txt"), title: "Codul de Procedură Civilă"},
	"proc_penal": {path: filepath.Join(codesTextDir, "coduldeprocedurapenala.txt"), title: "Codul de Procedură Penală"},
}

// parsedCache holds a limited set of parsed codes in memory. Since the parsed
// structures can be very large, we keep only a few most recently used entries
// to avoid exhausting memory.
var (
	parsedCache   = make(map[string]*cachedParsed)
	parsedOrder   = list.New()
	cacheMu       sync.Mutex
	maxCacheItems = 2
)

type cachedParsed struct {
	data *ParsedCode
	id   string
	elem *list.Element
}

func cacheGet(id string) (*ParsedCode, bool) {
	cacheMu.Lock()
	defer cacheMu.Unlock()
	if c, ok := parsedCache[id]; ok {
		parsedOrder.MoveToFront(c.elem)
		return c.data, true
	}
	return nil, false
}

func cacheAdd(id string, pc *ParsedCode) {
	cacheMu.Lock()
	defer cacheMu.Unlock()
	if c, ok := parsedCache[id]; ok {
		c.data = pc
		parsedOrder.MoveToFront(c.elem)
		return
	}
	e := parsedOrder.PushFront(id)
	parsedCache[id] = &cachedParsed{data: pc, id: id, elem: e}
	if parsedOrder.Len() > maxCacheItems {
		back := parsedOrder.Back()
		if back != nil {
			oldID := back.Value.(string)
			parsedOrder.Remove(back)
			delete(parsedCache, oldID)
		}
	}
}

type SimpleCode struct {
	ID          string `json:"id"`
	Title       string `json:"title"`
	Content     string `json:"content"`
	LastUpdated string `json:"lastUpdated"`
}

var codes = make(map[string]*SimpleCode)

var codesFile = filepath.Join(rootDir, "dashbord-react", "codes.json")
var codesTextDir = filepath.Join(rootDir, "backend", "codurileactualizate")

func loadCodes() {
	data, err := os.ReadFile(codesFile)
	if err != nil {
		data = []byte("[]")
	}
	var arr []SimpleCode
	if json.Unmarshal(data, &arr) != nil {
		return
	}
	for i := range arr {
		c := arr[i]
		if c.LastUpdated == "" {
			c.LastUpdated = time.Now().Format(time.RFC3339)
		}
		if c.Content == "" {
			txtPath := filepath.Join(codesTextDir, c.ID+".txt")
			if b, err := os.ReadFile(txtPath); err == nil {
				c.Content = string(b)
			}
		}
		codes[c.ID] = &c
	}
}

func saveCodes() {
	arr := make([]SimpleCode, 0, len(codes))
	for _, c := range codes {
		arr = append(arr, *c)
	}
	data, err := json.MarshalIndent(arr, "", "  ")
	if err != nil {
		return
	}
	_ = os.WriteFile(codesFile, data, 0644)
}

// preloadParsedCodes ensures all known code files are parsed once at startup
// and cached as JSON files next to the React dashboard. This avoids expensive
// parsing on each request and guarantees the dashboard can load the structured
// data even if parsing fails later on.
func preloadParsedCodes() {
	for id, info := range codeFiles {
		jsonPath := filepath.Join(rootDir, "dashbord-react", fmt.Sprintf("code_%s.json", id))
		if _, err := os.Stat(jsonPath); err == nil {
			// already generated
			continue
		}
		pc, err := parseCodeFile(info.path, id, info.title)
		if err != nil {
			fmt.Println("failed to parse", id, "-", err)
			continue
		}
		pc.LastUpdated = time.Now().Format(time.RFC3339)
		if data, err := json.MarshalIndent(pc, "", "  "); err == nil {
			_ = os.WriteFile(jsonPath, data, 0644)
		}
	}
}

func getParsedCodeHandler(c *gin.Context) {
	id := c.Param("id")
	jsonPath := filepath.Join(rootDir, "dashbord-react", fmt.Sprintf("code_%s.json", id))
	if _, err := os.Stat(jsonPath); err == nil {
		c.File(jsonPath)
		return
	}
	pc, err := loadParsedCode(id)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "code not found"})
		return
	}
	c.JSON(http.StatusOK, pc)
}

func saveParsedCodeHandler(c *gin.Context) {
	id := c.Param("id")
	var pc ParsedCode
	if err := c.BindJSON(&pc); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid payload"})
		return
	}
	cacheAdd(id, &pc)
	jsonPath := filepath.Join(rootDir, "dashbord-react", fmt.Sprintf("code_%s.json", id))
	if data, err := json.MarshalIndent(pc, "", "  "); err == nil {
		if err := os.WriteFile(jsonPath, data, 0644); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
	}
	c.Status(http.StatusOK)
}

// getCodeTextJSON returns the stored structured code text, if any.
func getCodeTextJSON(c *gin.Context) {
	id := c.Param("id")
	path := filepath.Join(rootDir, "dashbord-react", fmt.Sprintf("codetext_%s.json", id))
	data, err := os.ReadFile(path)
	if err != nil {
		if os.IsNotExist(err) {
			c.JSON(http.StatusNotFound, gin.H{"error": "not found"})
		} else {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		}
		return
	}
	c.Data(http.StatusOK, "application/json", data)
}

// saveCodeTextJSON stores the structured code text as JSON.
func saveCodeTextJSON(c *gin.Context) {
	id := c.Param("id")
	var payload interface{}
	if err := c.BindJSON(&payload); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid payload"})
		return
	}
	data, err := json.MarshalIndent(payload, "", "  ")
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	path := filepath.Join(rootDir, "dashbord-react", fmt.Sprintf("codetext_%s.json", id))
	if err := os.WriteFile(path, data, 0644); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	txt := convertSectionsToText(payload)
	_ = os.WriteFile(filepath.Join(codesTextDir, id+".txt"), []byte(txt), 0644)

	c.Status(http.StatusOK)
}

func convertSectionsToText(v interface{}) string {
	var lines []string
	var walk func(interface{})
	walk = func(item interface{}) {
		m, ok := item.(map[string]interface{})
		if !ok {
			return
		}
		if t, ok := m["type"].(string); ok {
			switch t {
			case "Note", "Decision":
				lines = append(lines, t)
				if arr, ok := m["content"].([]interface{}); ok {
					for _, l := range arr {
						lines = append(lines, fmt.Sprint(l))
					}
				}
				return
			default:
				name := fmt.Sprint(m["name"])
				if name != "" {
					lines = append(lines, fmt.Sprintf("%s %s", t, name))
				}
				if arr, ok := m["content"].([]interface{}); ok {
					for _, sub := range arr {
						walk(sub)
					}
				}
				return
			}
		}
		if _, ok := m["number"]; ok {
			num := fmt.Sprint(m["number"])
			title := strings.TrimSpace(fmt.Sprint(m["title"]))
			if title != "" {
				lines = append(lines, fmt.Sprintf("Articolul %s - %s", num, title))
			} else {
				lines = append(lines, fmt.Sprintf("Articolul %s", num))
			}
			if arr, ok := m["content"].([]interface{}); ok {
				for _, l := range arr {
					lines = append(lines, fmt.Sprint(l))
				}
			}
			if arr, ok := m["amendments"].([]interface{}); ok {
				for _, l := range arr {
					lines = append(lines, fmt.Sprint(l))
				}
			}
		}
	}

	if arr, ok := v.([]interface{}); ok {
		for _, item := range arr {
			walk(item)
		}
	}
	return strings.Join(lines, "\n")
}

func loadParsedCode(id string) (*ParsedCode, error) {
	if pc, ok := cacheGet(id); ok {
		return pc, nil
	}

	jsonPath := filepath.Join(rootDir, "dashbord-react", fmt.Sprintf("code_%s.json", id))
	if data, err := os.ReadFile(jsonPath); err == nil {
		var pc ParsedCode
		if json.Unmarshal(data, &pc) == nil {
			cacheAdd(id, &pc)
			return &pc, nil
		}
	}

	info, ok := codeFiles[id]
	if !ok {
		return nil, fmt.Errorf("unknown code id")
	}

	pc, err := parseCodeFile(info.path, id, info.title)
	if err != nil {
		return nil, err
	}
	pc.LastUpdated = time.Now().Format(time.RFC3339)
	cacheAdd(id, pc)

	if data, err := json.MarshalIndent(pc, "", "  "); err == nil {
		_ = os.WriteFile(jsonPath, data, 0644)
	}
	return pc, nil
}

// getDashboardPath returns an absolute path to the React control panel
// directory so the server works regardless of the working directory.
func getDashboardPath() string {
	// first try the path derived from the detected repository root
	candidates := []string{
		filepath.Join(rootDir, "dashbord-react", "dist"),
		filepath.Join(rootDir, "dashbord-react"),
	}
	for _, p := range candidates {
		if _, err := os.Stat(p); err == nil {
			return p
		}
	}

	// next try paths relative to the current working directory as this
	// is the common case when running `go run .` during development
	if wd, err := os.Getwd(); err == nil {
		candidates := []string{
			filepath.Join(wd, "dashbord-react", "dist"),
			filepath.Join(wd, "..", "dashbord-react", "dist"),
			filepath.Join(wd, "dashbord-react"),
			filepath.Join(wd, "..", "dashbord-react"),
		}
		for _, p := range candidates {
			if _, err := os.Stat(p); err == nil {
				return p
			}
		}
	}

	// fall back to paths relative to the executable. This helps when the
	// server is built and executed from another directory.
	if exe, err := os.Executable(); err == nil {
		candidates := []string{
			filepath.Join(filepath.Dir(exe), "dashbord-react", "dist"),
			filepath.Join(filepath.Dir(exe), "..", "dashbord-react", "dist"),
			filepath.Join(filepath.Dir(exe), "dashbord-react"),
			filepath.Join(filepath.Dir(exe), "..", "dashbord-react"),
		}
		for _, p := range candidates {
			if _, err := os.Stat(p); err == nil {
				return p
			}
		}
	}

	// final fallback keeps previous behaviour
	return filepath.Join(rootDir, "dashbord-react")
}

func saveBooks(c *gin.Context) {
	var books []map[string]interface{}
	if err := c.BindJSON(&books); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid payload"})
		return
	}
	data, err := json.MarshalIndent(books, "", "  ")
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	if err := os.WriteFile(filepath.Join(rootDir, "dashbord-react", "books.json"), data, 0644); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.Status(http.StatusOK)
}

func listBooks(c *gin.Context) {
	data, err := ioutil.ReadFile(filepath.Join(rootDir, "dashbord-react", "books.json"))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	var books []map[string]interface{}
	if err := json.Unmarshal(data, &books); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, books)
}

func saveNews(c *gin.Context) {
	var news []map[string]interface{}
	if err := c.BindJSON(&news); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid payload"})
		return
	}
	data, err := json.MarshalIndent(news, "", "  ")
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	if err := os.WriteFile(filepath.Join(rootDir, "dashbord-react", "news.json"), data, 0644); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.Status(http.StatusOK)
}

func listNews(c *gin.Context) {
	data, err := ioutil.ReadFile(filepath.Join(rootDir, "dashbord-react", "news.json"))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	var news []map[string]interface{}
	if err := json.Unmarshal(data, &news); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, news)
}

func saveTests(c *gin.Context) {
	var tests []map[string]interface{}
	if err := c.BindJSON(&tests); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid payload"})
		return
	}
	data, err := json.MarshalIndent(tests, "", "  ")
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	if err := os.WriteFile(filepath.Join(rootDir, "backend", "tests.json"), data, 0644); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.Status(http.StatusOK)
}

func listTests(c *gin.Context) {
	path := filepath.Join(rootDir, "backend", "tests.json")
	data, err := ioutil.ReadFile(path)
	if os.IsNotExist(err) {
		data = []byte("[]")
	} else if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	var tests []map[string]interface{}
	if err := json.Unmarshal(data, &tests); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, tests)
}

func uploadNewsImage(c *gin.Context) {
	file, err := c.FormFile("image")
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "missing file"})
		return
	}

	os.MkdirAll("uploads/noutati", os.ModePerm)
	filename := uuid.New().String() + filepath.Ext(file.Filename)
	path := filepath.Join("uploads", "noutati", filename)
	if err := c.SaveUploadedFile(file, path); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to save"})
		return
	}

	scheme := "http"
	if c.Request.TLS != nil {
		scheme = "https"
	}
	host := c.Request.Host
	url := fmt.Sprintf("%s://%s/uploads/noutati/%s", scheme, host, filename)

	c.JSON(http.StatusOK, gin.H{"url": url})
}

func register(c *gin.Context) {
	var u User
	if err := c.BindJSON(&u); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid payload"})
		return
	}
	mu.Lock()
	defer mu.Unlock()
	if _, exists := users[u.Username]; exists {
		c.JSON(http.StatusConflict, gin.H{"error": "user exists"})
		return
	}
	for _, existing := range users {
		if existing.Email == u.Email {
			c.JSON(http.StatusConflict, gin.H{"error": "email exists"})
			return
		}
	}
	u.ID = uuid.New().String()
	users[u.Username] = u
	saveUsers()
	c.JSON(http.StatusCreated, gin.H{"user": u})
}

func login(c *gin.Context) {
	var u User
	if err := c.BindJSON(&u); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid payload"})
		return
	}
	mu.Lock()
	defer mu.Unlock()

	var stored User
	var exists bool

	// Allow login using either username or email for convenience
	if u.Username != "" {
		stored, exists = users[u.Username]
	}
	if !exists && u.Email != "" {
		for _, usr := range users {
			if usr.Email == u.Email {
				stored = usr
				exists = true
				break
			}
		}
	}

	if !exists || stored.Password != u.Password {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "invalid credentials"})
		return
	}
	token := uuid.New().String()
	tokens[token] = stored.Username
	saveTokens()
	c.JSON(http.StatusOK, gin.H{"token": token, "user": stored})
}

func listFiles(c *gin.Context) {
	var files []string
	filepath.Walk("..", func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}
		if !info.IsDir() {
			files = append(files, path)
		}
		return nil
	})
	c.JSON(http.StatusOK, gin.H{"files": files})
}

type CodeInfo struct {
	ID          string `json:"id"`
	Title       string `json:"title"`
	LastUpdated string `json:"lastUpdated"`
}

// listCodes returns all codes saved via the React dashboard.
func listCodes(c *gin.Context) {
	list := []CodeInfo{}
	for _, cde := range codes {
		list = append(list, CodeInfo{ID: cde.ID, Title: cde.Title, LastUpdated: cde.LastUpdated})
	}
	c.JSON(http.StatusOK, list)
}

func getCode(c *gin.Context) {
	id := c.Param("id")
	if cd, ok := codes[id]; ok {
		c.JSON(http.StatusOK, cd)
		return
	}
	c.JSON(http.StatusNotFound, gin.H{"error": "code not found"})
}

// getCodeTextHandler serves the raw text of a legal code so the dashboard can
// display the original file contents when needed.
func getCodeTextHandler(c *gin.Context) {
	id := c.Param("id")
	info, ok := codeFiles[id]
	if !ok {
		c.JSON(http.StatusNotFound, gin.H{"error": "code not found"})
		return
	}
	data, err := os.ReadFile(info.path)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.Data(http.StatusOK, "text/plain; charset=utf-8", data)
}

func saveCode(c *gin.Context) {
	id := c.Param("id")
	var payload SimpleCode
	if err := c.BindJSON(&payload); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid payload"})
		return
	}
	payload.ID = id
	payload.LastUpdated = time.Now().Format(time.RFC3339)
	codes[id] = &payload
	saveCodes()
	c.Status(http.StatusOK)
}

func profile(c *gin.Context) {
	token := c.GetHeader("Authorization")
	if strings.HasPrefix(token, "Bearer ") {
		token = strings.TrimPrefix(token, "Bearer ")
	}
	if token == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "missing token"})
		return
	}
	username, ok := tokens[token]
	if !ok {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "invalid token"})
		return
	}
	mu.Lock()
	user, exists := users[username]
	mu.Unlock()
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "invalid token"})
		return
	}
	c.JSON(http.StatusOK, user)
}

func getUserFromToken(token string) (User, bool) {
	if strings.HasPrefix(token, "Bearer ") {
		token = strings.TrimPrefix(token, "Bearer ")
	}
	mu.Lock()
	defer mu.Unlock()
	username, ok := tokens[token]
	if !ok {
		return User{}, false
	}
	user, exists := users[username]
	return user, exists
}

func updateProfile(c *gin.Context) {
	token := c.GetHeader("Authorization")
	user, ok := getUserFromToken(token)
	if !ok {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "unauthorized"})
		return
	}

	var payload struct {
		Username string `json:"username"`
		Email    string `json:"email"`
		Bio      string `json:"bio"`
		Phone    string `json:"phone"`
	}
	if err := c.BindJSON(&payload); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid payload"})
		return
	}

	mu.Lock()
	original := user.Username
	if payload.Username != "" && payload.Username != user.Username {
		user.Username = payload.Username
	}
	if payload.Email != "" {
		user.Email = payload.Email
	}
	if payload.Bio != "" {
		user.Bio = payload.Bio
	}
	if payload.Phone != "" {
		user.Phone = payload.Phone
	}

	// update maps if username changed
	if original != user.Username {
		for t, u := range tokens {
			if u == original {
				tokens[t] = user.Username
			}
		}
		delete(users, original)
		saveTokens()
	}
	users[user.Username] = user
	saveUsers()
	mu.Unlock()

	c.JSON(http.StatusOK, user)
}

func uploadAvatar(c *gin.Context) {
	token := c.GetHeader("Authorization")
	user, ok := getUserFromToken(token)
	if !ok {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "unauthorized"})
		return
	}

	file, err := c.FormFile("avatar")
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "missing file"})
		return
	}

	os.MkdirAll("uploads/avatars", os.ModePerm)
	filename := uuid.New().String() + filepath.Ext(file.Filename)
	path := filepath.Join("uploads", "avatars", filename)
	if err := c.SaveUploadedFile(file, path); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to save"})
		return
	}

	scheme := "http"
	if c.Request.TLS != nil {
		scheme = "https"
	}
	host := c.Request.Host
	user.AvatarURL = fmt.Sprintf("%s://%s/uploads/avatars/%s", scheme, host, filename)

	mu.Lock()
	users[user.Username] = user
	saveUsers()
	mu.Unlock()

	c.JSON(http.StatusOK, user)
}

func uploadBookImage(c *gin.Context) {
	file, err := c.FormFile("image")
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "missing file"})
		return
	}

	os.MkdirAll("uploads/books", os.ModePerm)
	filename := uuid.New().String() + filepath.Ext(file.Filename)
	path := filepath.Join("uploads", "books", filename)
	if err := c.SaveUploadedFile(file, path); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to save"})
		return
	}

	scheme := "http"
	if c.Request.TLS != nil {
		scheme = "https"
	}
	host := c.Request.Host
	url := fmt.Sprintf("%s://%s/uploads/books/%s", scheme, host, filename)

	c.JSON(http.StatusOK, gin.H{"url": url})
}

func wsHandler(c *gin.Context) {
	token := c.GetHeader("Authorization")
	if token == "" {
		token = c.Query("token")
	}
	user, ok := getUserFromToken(token)
	if !ok {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "unauthorized"})
		return
	}

	upgrader := websocket.Upgrader{
		ReadBufferSize:  1024,
		WriteBufferSize: 1024,
		CheckOrigin: func(r *http.Request) bool {
			return true
		},
	}

	conn, err := upgrader.Upgrade(c.Writer, c.Request, nil)
	if err != nil {
		return
	}

	wsClients[user.ID] = conn

	for {
		var msg map[string]interface{}
		if err := conn.ReadJSON(&msg); err != nil {
			break
		}
	}

	delete(wsClients, user.ID)
	conn.Close()
}

func getConversationsHandler(c *gin.Context) {
	token := c.GetHeader("Authorization")
	user, ok := getUserFromToken(token)
	if !ok {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "unauthorized"})
		return
	}

	convs := userConversations[user.ID]
	if convs == nil {
		convs = []*Conversation{}
	}

	c.JSON(http.StatusOK, convs)
}

func getMessagesHandler(c *gin.Context) {
	token := c.GetHeader("Authorization")
	user, ok := getUserFromToken(token)
	if !ok {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "unauthorized"})
		return
	}

	convID := c.Param("id")
	conv, exists := conversations[convID]
	if !exists || (conv.Participants[0] != user.ID && conv.Participants[1] != user.ID) {
		c.JSON(http.StatusNotFound, gin.H{"error": "conversation not found"})
		return
	}
	c.JSON(http.StatusOK, conv.Messages)
}

func sendMessageHandler(c *gin.Context) {
	token := c.GetHeader("Authorization")
	sender, ok := getUserFromToken(token)
	if !ok {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "unauthorized"})
		return
	}

	recipientID := c.Param("id")

	var payload struct {
		Text string `json:"text"`
	}
	if err := c.BindJSON(&payload); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid payload"})
		return
	}

	// find or create conversation
	var conv *Conversation
	for _, c := range userConversations[sender.ID] {
		if len(c.Participants) == 2 && ((c.Participants[0] == sender.ID && c.Participants[1] == recipientID) || (c.Participants[1] == sender.ID && c.Participants[0] == recipientID)) {
			conv = c
			break
		}
	}
	if conv == nil {
		convID := uuid.New().String()
		conv = &Conversation{
			ID:           convID,
			Participants: []string{sender.ID, recipientID},
			Messages:     []Message{},
			LastActivity: time.Now(),
			UnreadCount:  map[string]int{sender.ID: 0, recipientID: 0},
		}
		conversations[convID] = conv
		userConversations[sender.ID] = append(userConversations[sender.ID], conv)
		userConversations[recipientID] = append(userConversations[recipientID], conv)
	}

	msg := Message{
		ID:             uuid.New().String(),
		ConversationID: conv.ID,
		SenderID:       sender.ID,
		RecipientID:    recipientID,
		Text:           payload.Text,
		Timestamp:      time.Now(),
	}

	conv.Messages = append([]Message{msg}, conv.Messages...)
	conv.LastActivity = msg.Timestamp
	conv.UnreadCount[recipientID] += 1

	// notify recipient via websocket
	if ws, ok := wsClients[recipientID]; ok {
		ws.WriteJSON(gin.H{
			"type":         "new_message",
			"conversation": conv,
			"message":      msg,
		})
	}

	c.JSON(http.StatusOK, gin.H{"conversation": conv, "message": msg})
}

func markReadHandler(c *gin.Context) {
	token := c.GetHeader("Authorization")
	user, ok := getUserFromToken(token)
	if !ok {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "unauthorized"})
		return
	}

	messageID := c.Param("id")
	for _, conv := range userConversations[user.ID] {
		for i, m := range conv.Messages {
			if m.ID == messageID {
				conv.Messages[i].IsRead = true
				conv.UnreadCount[user.ID] = 0
				c.Status(http.StatusOK)
				return
			}
		}
	}

	c.JSON(http.StatusNotFound, gin.H{"error": "message not found"})
}

func getUtilsHandler(c *gin.Context) {
	token := c.GetHeader("Authorization")
	user, ok := getUserFromToken(token)
	if !ok {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "unauthorized"})
		return
	}

	mu.Lock()
	data, exists := userUtils[user.ID]
	mu.Unlock()
	if !exists {
		data = map[string]interface{}{}
	}

	c.JSON(http.StatusOK, data)
}

func updateUtilsHandler(c *gin.Context) {
	token := c.GetHeader("Authorization")
	user, ok := getUserFromToken(token)
	if !ok {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "unauthorized"})
		return
	}

	var payload map[string]interface{}
	if err := c.BindJSON(&payload); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid payload"})
		return
	}

	mu.Lock()
	existing, ok := userUtils[user.ID]
	if !ok {
		existing = make(map[string]interface{})
	}
	for k, v := range payload {
		existing[k] = v
	}
	userUtils[user.ID] = existing
	mu.Unlock()

	c.JSON(http.StatusOK, gin.H{"status": "ok"})
}

func getPrefSlice(prefs *ArticlePrefs, kind string) []string {
	switch kind {
	case "likes":
		return prefs.Likes
	case "favorites":
		return prefs.Favorites
	case "saved":
		return prefs.Saved
	}
	return []string{}
}

func togglePref(prefs *ArticlePrefs, kind, id string) {
	slice := getPrefSlice(prefs, kind)
	found := false
	for i, v := range slice {
		if v == id {
			slice = append(slice[:i], slice[i+1:]...)
			found = true
			break
		}
	}
	if !found {
		slice = append(slice, id)
	}
	switch kind {
	case "likes":
		prefs.Likes = slice
	case "favorites":
		prefs.Favorites = slice
	case "saved":
		prefs.Saved = slice
	}
}

func getArticlePrefsHandler(kind string) gin.HandlerFunc {
	return func(c *gin.Context) {
		token := c.GetHeader("Authorization")
		user, ok := getUserFromToken(token)
		if !ok {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "unauthorized"})
			return
		}
		mu.Lock()
		prefs, ok := userArticlePrefs[user.ID]
		if !ok {
			prefs = &ArticlePrefs{}
			userArticlePrefs[user.ID] = prefs
		}
		data := getPrefSlice(prefs, kind)
		mu.Unlock()
		c.JSON(http.StatusOK, gin.H{kind: data})
	}
}

func toggleArticlePrefsHandler(kind string) gin.HandlerFunc {
	return func(c *gin.Context) {
		token := c.GetHeader("Authorization")
		user, ok := getUserFromToken(token)
		if !ok {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "unauthorized"})
			return
		}
		var payload struct {
			ID string `json:"id"`
		}
		if err := c.BindJSON(&payload); err != nil || payload.ID == "" {
			c.JSON(http.StatusBadRequest, gin.H{"error": "invalid payload"})
			return
		}
		mu.Lock()
		prefs, ok := userArticlePrefs[user.ID]
		if !ok {
			prefs = &ArticlePrefs{}
			userArticlePrefs[user.ID] = prefs
		}
		togglePref(prefs, kind, payload.ID)
		saveArticlePrefs()
		data := getPrefSlice(prefs, kind)
		mu.Unlock()
		c.JSON(http.StatusOK, gin.H{kind: data})
	}
}

func getOnlineUsersHandler(c *gin.Context) {
	mu.Lock()
	users := make([]string, 0, len(wsClients))
	for id := range wsClients {
		users = append(users, id)
	}
	mu.Unlock()
	c.JSON(http.StatusOK, gin.H{"onlineUsers": users})
}

func searchUsersHandler(c *gin.Context) {
	query := strings.ToLower(c.Query("query"))
	if query == "" {
		c.JSON(http.StatusOK, []User{})
		return
	}

	mu.Lock()
	defer mu.Unlock()

	var results []User
	for _, u := range users {
		if strings.Contains(strings.ToLower(u.Username), query) ||
			(u.Email != "" && strings.Contains(strings.ToLower(u.Email), query)) {
			results = append(results, u)
		}
	}
	c.JSON(http.StatusOK, results)
}

func getUserByID(id string) (User, bool) {
	for _, u := range users {
		if u.ID == id {
			return u, true
		}
	}
	return User{}, false
}

func getUserHandler(c *gin.Context) {
	id := c.Param("id")
	mu.Lock()
	user, ok := getUserByID(id)
	mu.Unlock()
	if !ok {
		c.JSON(http.StatusNotFound, gin.H{"error": "user not found"})
		return
	}
	c.JSON(http.StatusOK, user)
}

func toggleFollowHandler(c *gin.Context) {
	token := c.GetHeader("Authorization")
	current, ok := getUserFromToken(token)
	if !ok {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "unauthorized"})
		return
	}

	targetID := c.Param("id")

	mu.Lock()
	defer mu.Unlock()

	target, exists := getUserByID(targetID)
	if !exists {
		c.JSON(http.StatusNotFound, gin.H{"error": "user not found"})
		return
	}

	// check if already following
	following := false
	for _, id := range current.Following {
		if id == targetID {
			following = true
			break
		}
	}

	if following {
		// unfollow
		var newFollowing []string
		for _, id := range current.Following {
			if id != targetID {
				newFollowing = append(newFollowing, id)
			}
		}
		current.Following = newFollowing

		var newFollowers []string
		for _, id := range target.Followers {
			if id != current.ID {
				newFollowers = append(newFollowers, id)
			}
		}
		target.Followers = newFollowers
		following = false
	} else {
		current.Following = append(current.Following, targetID)
		target.Followers = append(target.Followers, current.ID)
		following = true
	}

	users[current.Username] = current
	users[target.Username] = target
	saveUsers()

	c.JSON(http.StatusOK, gin.H{"user": current, "isFollowing": following})
}

func getFollowersHandler(c *gin.Context) {
	token := c.GetHeader("Authorization")
	user, ok := getUserFromToken(token)
	if !ok {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "unauthorized"})
		return
	}

	mu.Lock()
	defer mu.Unlock()

	var followers []User
	for _, id := range user.Followers {
		if u, ok := getUserByID(id); ok {
			followers = append(followers, u)
		}
	}

	c.JSON(http.StatusOK, gin.H{"followers": followers})
}

func getFollowingHandler(c *gin.Context) {
	token := c.GetHeader("Authorization")
	user, ok := getUserFromToken(token)
	if !ok {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "unauthorized"})
		return
	}

	mu.Lock()
	defer mu.Unlock()

	var following []User
	for _, id := range user.Following {
		if u, ok := getUserByID(id); ok {
			following = append(following, u)
		}
	}

	c.JSON(http.StatusOK, gin.H{"following": following})
}

func main() {
	fmt.Println("Using repository root:", rootDir)
	loadUsers()
	loadTokens()
	loadCodes()
	loadArticlePrefs()
	preloadParsedCodes()
	r := gin.Default()

	r.Use(func(c *gin.Context) {
		c.Writer.Header().Set("Access-Control-Allow-Origin", "*")
		c.Writer.Header().Set("Access-Control-Allow-Methods", "GET,POST,PUT,DELETE,OPTIONS")
		c.Writer.Header().Set("Access-Control-Allow-Headers", "Authorization, Content-Type")
		if c.Request.Method == http.MethodOptions {
			c.AbortWithStatus(204)
			return
		}
		c.Next()
	})

	api := r.Group("/api")
	{
		// Legacy routes
		api.POST("/register", register)
		api.POST("/login", login)

		auth := api.Group("/auth")
		{
			auth.POST("/register", register)
			auth.POST("/login", login)
		}

		api.GET("/profile", profile)
		api.PUT("/profile", updateProfile)
		api.POST("/profile/avatar", uploadAvatar)
		api.GET("/files", listFiles)
		api.GET("/codes", listCodes)
		api.GET("/codes/:id", getCode)
		api.GET("/code-text/:id", getCodeTextHandler)
		api.GET("/code-text-json/:id", getCodeTextJSON)
		api.POST("/save-code-text/:id", saveCodeTextJSON)
		api.GET("/parsed-code/:id", getParsedCodeHandler)
		api.POST("/save-parsed-code/:id", saveParsedCodeHandler)

		api.GET("/utils", getUtilsHandler)
		api.PUT("/utils", updateUtilsHandler)

		api.GET("/favorites", getArticlePrefsHandler("favorites"))
		api.POST("/favorites", toggleArticlePrefsHandler("favorites"))
		api.GET("/likes", getArticlePrefsHandler("likes"))
		api.POST("/likes", toggleArticlePrefsHandler("likes"))
		api.GET("/saved", getArticlePrefsHandler("saved"))
		api.POST("/saved", toggleArticlePrefsHandler("saved"))

		api.GET("/users/online", getOnlineUsersHandler)

		api.GET("/users/search", searchUsersHandler)
		api.GET("/users/:id", getUserHandler)
		api.POST("/users/:id/follow", toggleFollowHandler)
		api.GET("/users/followers", getFollowersHandler)
		api.GET("/users/following", getFollowingHandler)

		api.GET("/conversations", getConversationsHandler)
		api.GET("/conversations/:id/messages", getMessagesHandler)
		api.POST("/messages/send/:id", sendMessageHandler)
		api.POST("/messages/mark-read/:id", markReadHandler)
		api.GET("/ws", wsHandler)

		api.GET("/books", listBooks)
		api.POST("/save-books", saveBooks)
		api.POST("/books/upload-image", uploadBookImage)

		api.GET("/news", listNews)
		api.POST("/save-news", saveNews)
		api.POST("/news/upload-image", uploadNewsImage)

		api.GET("/tests", listTests)
		api.POST("/save-tests", saveTests)

		api.POST("/save-code/:id", saveCode)
	}

	// serve React control panel
	r.Static("/controlpanel", getDashboardPath())

	r.Static("/uploads", "./uploads")

	// Listen on localhost. If you need to access the API from other
	// devices on your network, bind to your machine's IP or "0.0.0.0".
	r.Run("0.0.0.0:8080")
}
