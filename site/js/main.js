// Grabs the query strings and puts them into urlParams
var urlParams;

(function() {
    window.onpopstate = function () {
        var match,
        pl     = /\+/g,  // Regex for replacing addition symbol with a space
        search = /([^&=]+)=?([^&]*)/g,
        decode = function (s) { return decodeURIComponent(s.replace(pl, " ")); },
        query  = window.location.search.substring(1);

        urlParams = {};
        while (match = search.exec(query))
        urlParams[decode(match[1])] = decode(match[2]);
    }
    window.onpopstate();
})();

connectStr = 'http://164.76.124.33:1935/live/' + urlParams.streamName + '/playlist.m3u8';

function loadPlayer() {
    var playerElement = document.getElementById("player-wrapper");

    var player = new Clappr.Player({
        source: connectStr,
        poster: 'images/emu-logo.jpg',
        height: 480,
        width: 640,
        mediacontrol: {seekbar: "#00870e", buttons: "#004709"},
        autoPlay: true
    });

    player.attachTo(playerElement);
}
