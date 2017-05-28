/*function token() {
    if ( localStorage.getItem("token") == null ) {
        return "";
    }

    try {
        return JSON.parse(localStorage.getItem("token")).token;
    }
    catch(e) {
        return "";
    }
}

var flags = {
    "token": token(),
    "time": Date.now()
};*/

var app = Elm.Main.fullscreen(/*flags*/);
