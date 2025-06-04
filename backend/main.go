package main

import (
	"encoding/json"
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

type User struct {
	ID        string `json:"id"`
	Username  string `json:"username"`
	Email     string `json:"email"`
	Password  string `json:"password"`
	Bio       string `json:"bio,omitempty"`
	AvatarURL string `json:"avatarUrl,omitempty"`
	Phone     string `json:"phone,omitempty"`
}

var users = make(map[string]User)
var tokens = make(map[string]string) // token -> username
var mu sync.Mutex
var userUtils = make(map[string]map[string]interface{})

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

// getDashboardPath returns an absolute path to the React control panel
// directory so the server works regardless of the working directory.
func getDashboardPath() string {
	exe, err := os.Executable()
	if err != nil {
		return "../dashbord"
	}
	return filepath.Join(filepath.Dir(exe), "..", "dashbord")
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
	if err := os.WriteFile("../dashbord/books.json", data, 0644); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.Status(http.StatusOK)
}

func listBooks(c *gin.Context) {
	data, err := ioutil.ReadFile("../dashbord/books.json")
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
	u.ID = uuid.New().String()
	users[u.Username] = u
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

func getCode(c *gin.Context) {
	id := c.Param("id")

	files := map[string]struct {
		path  string
		title string
	}{
		"civil":      {"codes/codulcivil.txt", "Codul Civil"},
		"penal":      {"codes/codulpenal.txt", "Codul Penal"},
		"proc_civil": {"codes/coduldeproceduracivila.txt", "Codul de Procedură Civilă"},
		"proc_penal": {"codes/coduldeprocedurapenala.txt", "Codul de Procedură Penală"},
	}

	f, ok := files[id]
	if !ok {
		c.JSON(http.StatusNotFound, gin.H{"error": "code not found"})
		return
	}

	code, err := parseCodeFile(f.path, id, f.title)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, code)
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
	}
	users[user.Username] = user
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

	user.AvatarURL = "/uploads/avatars/" + filename

	mu.Lock()
	users[user.Username] = user
	mu.Unlock()

	c.JSON(http.StatusOK, user)
}

func wsHandler(c *gin.Context) {
	token := c.GetHeader("Authorization")
	user, ok := getUserFromToken(token)
	if !ok {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "unauthorized"})
		return
	}

	conn, err := websocket.Upgrade(c.Writer, c.Request, nil, 1024, 1024)
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

func main() {
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
		api.GET("/codes/:id", getCode)

		api.GET("/utils", getUtilsHandler)
		api.PUT("/utils", updateUtilsHandler)

		api.GET("/conversations", getConversationsHandler)
		api.GET("/conversations/:id/messages", getMessagesHandler)
		api.POST("/messages/send/:id", sendMessageHandler)
		api.POST("/messages/mark-read/:id", markReadHandler)
		api.GET("/ws", wsHandler)

		api.GET("/books", listBooks)
		api.POST("/save-books", saveBooks)
	}

	// serve React control panel
	r.Static("/controlpanel", getDashboardPath())

	r.Static("/uploads", "./uploads")

	r.Run(":8080")
}
