package main

import (
	"flag"
	"fmt"
	"net/http"
	"unicode"

	log "github.com/Sirupsen/logrus"
)

func nrmlzPort(port string) (string, error) {
	if port[0] != ':' {
		port = ":" + port
	}

	for _, v := range port[1:] {
		if !unicode.IsDigit(v) {
			return "", fmt.Errorf("val %q not digit in %q", v, port)
		}
	}

	return port, nil
}

func main() {
	port := ":3000"

	flag.StringVar(&port, "port", port, "listen port")
	flag.Parse()

	var err error
	if port, err = nrmlzPort(port); err != nil {
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
