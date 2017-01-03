package main

import (
	"reflect"
	"sync"
	"time"

	"github.com/gorilla/websocket"
)

type timeOut struct {
	mu          sync.Mutex
	on          bool
	conn        *websocket.Conn
	id          int64
	notFoundMsg string
}

func newTimeOut(conn *websocket.Conn, id int64, notFoundMsg string) *timeOut {
	return &timeOut{
		conn:        conn,
		id:          id,
		mu:          sync.Mutex{},
		notFoundMsg: notFoundMsg,
	}
}

func (t *timeOut) setOn(status bool) {
	t.mu.Lock()
	defer t.mu.Unlock()

	t.on = status
}

func (t *timeOut) isOn() bool {
	t.mu.Lock()
	defer t.mu.Unlock()

	return t.on
}

func (t *timeOut) time() []byte {
	return []byte(time.Now().Format(time.UnixDate))
}

func (t *timeOut) runOutput(cancel chan struct{}) {
	err := t.conn.WriteMessage(websocket.TextMessage, []byte("connected"))
	if err != nil {
		log.Infof(t.notFoundMsg, t.id)
		return
	}

	for {
		select {
		case <-cancel:
			return
		case <-time.After(time.Second):
			if !t.isOn() {
				continue
			}

			if err := t.conn.WriteMessage(websocket.TextMessage, t.time()); err != nil {
				log.Infof(t.notFoundMsg, t.id)
				return
			}
		}
	}
}

func (t *timeOut) respMux(val []byte) (bool, []byte) {
	if reflect.DeepEqual(val, []byte("ping")) {
		return true, []byte("pong")
	}

	if reflect.DeepEqual(val, []byte("start")) {
		t.setOn(true)

		return false, []byte{}
	}

	if reflect.DeepEqual(val, []byte("stop")) {
		t.setOn(false)

		return false, []byte{}
	}

	return false, []byte{}
}

func (t *timeOut) monitorInput() {
	for {
		_, m, err := t.conn.ReadMessage()
		if err != nil {
			log.Infof(t.notFoundMsg, t.id)
			return
		}

		log.Infof("user #%d sent: %q", t.id, string(m))

		if ok, resp := t.respMux(m); ok {
			if err := t.conn.WriteMessage(websocket.TextMessage, resp); err != nil {
				log.Infof(t.notFoundMsg, t.id)
				return
			}
		}
	}
}
