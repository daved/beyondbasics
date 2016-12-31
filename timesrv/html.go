package main

import (
	"fmt"
	"net/http"
)

type htmlFiles map[string]string

func makeHTMLFiles(wsPort string) htmlFiles {
	fs := map[string]string{}

	fs["index.html"] = `<!DOCTYPE HTML>
<html>
<head>

<style>
.box {
	width: 100%;
}

.box .buffer {
	width: 50%;
	margin: auto;
}

.box label {
	font-weight: bold;
	display: block;
	margin: 1em;
}

.box label:after {
		content: ": "
}

.box textarea {
	width: 100%;
	height: 20em;
	display: block;
	resize: none;
}

.box button {
	float: right;
	margin: 1em;
}
</style>

<script type="text/javascript">
function Dump() {
	this.el = document.getElementById("dump");
	this.el.style.height = this.el.offsetWidth+"px";
	this.el.style.width = this.el.style.height;
}

Dump.prototype.updScroll = function() {
	this.el.scrollTop = this.el.scrollHeight;
};

Dump.prototype.setVal = function(val) {
	this.el.value = val;
	this.updScroll();
};

Dump.prototype.addVal = function(val) {
	if (this.el.value == "") {
		this.setVal(val);
		return;
	}

	this.el.value = this.el.value + "\n" + val;
	this.updScroll();
};

var dump;

function setup() {
	dump = new Dump();
}

var ws;
var addr = "ws://localhost` + wsPort + `/ws/example";

function startWS() {
	if (ws != null) {
		dump.addVal("cmd: connect (err: already connected)");
		return;
	}

	dump.setVal("cmd: connect");

	ws = new WebSocket(addr);
	ws.onopen = function() {
		dump.addVal("ntc: connected");
	};
	ws.onmessage = function(e) {
		dump.addVal("rcv: " + e.data);
	};
	ws.onclose = function() {
		dump.addVal("ntc: disconnected");
		ws = null;
	};
}

function sendWS(cmd) {
	if (ws == null) {
		dump.addVal("cmd: send: " + cmd + " (err: not connected)");
		return;
	}

	dump.addVal("cmd: send: " + cmd);
	ws.send(cmd);
}

function stopWS() {
	sendWS("quit");
	//ws.close();
}
</script>

</head>

<body onload="setup()">

<div class="box">
	<div class="buffer">
		<label for="dump">Data Dump</label>
		<textarea id="dump"></textarea>
		<button onclick="stopWS()">Disconnect</button>
		<button onclick="sendWS('ping')">Ping</button>
		<button onclick="startWS()">Connect</button>
	</div>
</div>

</body>
</html>`

	return fs
}

func (fs htmlFiles) serveFile(f string) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		d, ok := fs[f]
		if !ok {
			st := http.StatusNotFound
			http.Error(w, http.StatusText(st), st)
			return
		}

		fmt.Fprint(w, d)
	}
}
