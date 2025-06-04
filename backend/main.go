package main

import (
	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	"net/http"
	"os"
	"path/filepath"
	"sync"
)

type User struct {
	Username string `json:"username"`
	Password string `json:"password"`
}

var users = make(map[string]string)
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
	users[u.Username] = u.Password
	c.JSON(http.StatusOK, gin.H{"message": "registered"})
}

func login(c *gin.Context) {
	var u User
	if err := c.BindJSON(&u); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid payload"})
		return
	}
	mu.Lock()
	defer mu.Unlock()
	if pwd, exists := users[u.Username]; !exists || pwd != u.Password {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "invalid credentials"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "logged in"})
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

func main() {
	r := gin.Default()
	r.Use(cors.Default())

	api := r.Group("/api")
	{
		api.POST("/register", register)
		api.POST("/login", login)
		api.GET("/files", listFiles)
		api.GET("/codes/:id", getCode)
	}

	r.Run(":8080")
}
