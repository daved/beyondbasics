var flags = {
    'token': localStorage.getItem('token')
};

var app = Elm.Main.fullscreen(flags);

app.ports.saveToken.subscribe(function(token) {
    localStorage.setItem('token', token);
});
