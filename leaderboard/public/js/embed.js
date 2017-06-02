var TOKEN_KEY = 'token';

var flags = {};
flags[TOKEN_KEY] = localStorage.getItem(TOKEN_KEY);

var app = Elm.Main.fullscreen(flags);

app.ports.storeToken.subscribe(function(token) {
    localStorage.setItem(TOKEN_KEY, token);
});

app.ports.clearToken.subscribe(function() {
    localStorage.removeItem(TOKEN_KEY);
});
