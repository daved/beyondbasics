package main

import (
	"fmt"
	"net/http"
	"time"

	log "github.com/Sirupsen/logrus"
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

func (a *wsApp) runOutput(conn *websocket.Conn, id int64, cancel chan struct{}) {
	if err := conn.WriteMessage(websocket.TextMessage, []byte("connected")); err != nil {
		log.Infof(a.notFoundMsg, id)
		return
	}

	for {
		select {
		case <-cancel:
			return
		case <-time.After(time.Second):
			t := []byte(time.Now().Format(time.UnixDate))
			if err := conn.WriteMessage(websocket.TextMessage, t); err != nil {
				log.Infof(a.notFoundMsg, id)
				return
			}
		}
	}
}

func (a *wsApp) monitorInput(conn *websocket.Conn, id int64) {
	for {
		_, m, err := conn.ReadMessage()
		if err != nil {
			log.Infof(a.notFoundMsg, id)
			return
		}

		log.Infof("user #%d sent: %q", id, string(m))

		if string(m) == "ping" {
			if err := conn.WriteMessage(websocket.TextMessage, []byte("pong")); err != nil {
				log.Infof(a.notFoundMsg, id)
				return
			}

			continue
		}

		log.Infof("user #%d is being disconnected", id)

		if err := conn.WriteMessage(websocket.TextMessage, []byte("disconnecting")); err != nil {
		}

		return
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

	go a.runOutput(conn, id, cancel)
	a.monitorInput(conn, id)

	log.Infof("user #%d disconnected", id)
}
