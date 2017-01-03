package main

import (
	"fmt"
	"net/http"
	"time"

	"github.com/gorilla/websocket"
)

type wsApp struct {
	notFoundMsg string
	upgrader    websocket.Upgrader
}

func newWSApp() *wsApp {
	return &wsApp{
		notFoundMsg: "user #%d is not found",
		upgrader: websocket.Upgrader{
			ReadBufferSize:  1024,
			WriteBufferSize: 1024,
			CheckOrigin:     func(r *http.Request) bool { return true },
		},
	}
}

func (a *wsApp) exampleHandler(w http.ResponseWriter, r *http.Request) {
	id := time.Now().UnixNano()
	cancel := make(chan struct{})

	conn, err := a.upgrader.Upgrade(w, r, nil)
	if err != nil {
		fmt.Println(err)
		return
	}
	defer func() {
		close(cancel)

		if err := conn.Close(); err != nil {
			fmt.Println(err)
		}
	}()

	log.Infof("user #%d connected", id)
	log.Infof(a.notFoundMsg, id)

	to := newTimeOut(conn, id, a.notFoundMsg)
	go to.runOutput(cancel)
	to.monitorInput()

	log.Infof("user #%d disconnected", id)
}
