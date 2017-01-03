package main

import (
	"flag"
	"net/http"

	"github.com/codemodus/norm"
	"github.com/sirupsen/logrus"
)

var (
	log = logrus.New()
)

func main() {
	port := ":3000"

	flag.StringVar(&port, "port", port, "listen port")
	flag.Parse()

	var err error
	if port, err = norm.Port(port); err != nil {
		log.Panic(err)
	}

	fs := makeHTMLFiles(port)
	wsa := newWSApp()

	http.HandleFunc("/", fs.serveFile("index.html"))
	http.HandleFunc("/ws/example", wsa.exampleHandler)

	log.Infof("serving on %q", "http://localhost"+port)

	if err := http.ListenAndServe(port, nil); err != nil {
		log.Panic(err)
	}
}
