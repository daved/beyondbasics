var app = Elm.Main.fullscreen();

app.ports.setDocTitle.subscribe(function(title) {
    document.title = title;
});
