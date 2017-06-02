var flags = {
    'token': localStorage.getItem('token')
};

var app = Elm.Main.fullscreen(flags);

app.ports.storeToken.subscribe(function(token) {
    localStorage.setItem('token', token);
});

app.ports.clearToken.subscribe(function() {
    localStorage.removeItem('token');
});
