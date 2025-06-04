package main

import (
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"net/http"
	"os"
	"path/filepath"
	"strings"
	"sync"
)

type User struct {
	ID       string `json:"id"`
	Username string `json:"username"`
	Email    string `json:"email"`
	Password string `json:"password"`
}

var users = make(map[string]User)
var tokens = make(map[string]string) // token -> username
var mu sync.Mutex

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
	if id != "civil" {
		c.JSON(http.StatusNotFound, gin.H{"error": "code not found"})
		return
	}

	code, err := parseCodeFile("codes/codulcivil.txt")
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
		api.GET("/files", listFiles)
		api.GET("/codes/:id", getCode)
	}

	r.Run(":8080")
}
