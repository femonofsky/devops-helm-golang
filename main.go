package main

import (
	"fmt"
	"log"
	"net/http"
	"os"

	"github.com/gorilla/mux"
)

func newRouter() *mux.Router {
	r := mux.NewRouter()
	r.HandleFunc("/hello", handler).Methods("GET")

	// Declare the static file directory and point it to the
	// directory we just made
	r.PathPrefix("/").Handler(http.FileServer(http.Dir("./assets/")))


	return r
}

func main() {
	// Initialize Logger
	logger := log.New(os.Stdout, "web-app ", log.LstdFlags)
	logger.Println("Starting the application...")

	// The router is now formed by calling the `newRouter` constructor function
	// that we defined above. The rest of the code stays the same
	r := newRouter()

	// listens on the TCP network address addr
	http.ListenAndServe(":8080", r)
}

func handler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "Hello World!")
}