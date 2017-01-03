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
// Dump ...
function Dump(id) {
	this.el = document.getElementById(id);
	this.el.style.height = this.el.offsetWidth+"px";
	this.el.style.width = this.el.style.height;
}

Dump.prototype.updScroll = function() {
	this.el.scrollTop = this.el.scrollHeight;
};

Dump.prototype.SetVal = function(val) {
	this.el.value = val;
	this.updScroll();
};

Dump.prototype.AddVal = function(val) {
	if (this.el.value == "") {
		this.SetVal(val);
		return;
	}

	this.el.value = this.el.value + "\n" + val;
	this.updScroll();
};

// WS ...
function WS(addr, dumpId) {
	this.dump = new Dump(dumpId);
	this.Connect(addr);
}

WS.prototype.Connect = function(addr) {
	var dump = this.dump;

	if (this.conn != null) {
		dump.AddVal("cmd: connect: (err: already connected)");
		return;
	}

	dump.AddVal("cmd: connect");

	this.conn = new WebSocket(addr);
	this.conn.onopen = function() {
		dump.AddVal("ntc: connected");
	};
	this.conn.onmessage = function(e) {
		dump.AddVal("rcv: " + e.data);
	};
	this.conn.onclose = function() {
		dump.AddVal("ntc: disconnected");
	};
};

WS.prototype.Send = function(cmd) {
	if (this.conn == null) {
		this.dump.AddVal("cmd: send: " + cmd + " (err: not connected)");
		return;
	}

	this.dump.AddVal("cmd: send: " + cmd);
	this.conn.send(cmd);
};

// globals
var _ws;

// main
function main() {
	var addr = "ws://localhost` + wsPort + `/ws/example";
	var dumpId = "dump";

	_ws = new WS(addr, dumpId);
}
</script>

</head>

<body onload="main()">

<div class="box">
	<div class="buffer">
		<label for="dump">Data Dump</label>
		<textarea id="dump"></textarea>
		<button onclick="_ws.Send('stop')">Stop</button>
		<button onclick="_ws.Send('ping')">Ping</button>
		<button onclick="_ws.Send('start')">Start</button>
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
