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

function loadPlayer() {
    // Defaults
    var connectionString = '';
    var posterImage = 'images/emu-logo.jpg';
    var playerColor = "#006234";
    var playerHeight = 480;
    var playerWidth = 720;
    var autoPlay = false;
    
    if(urlParams.streamName) {   //if streamName has truthy value
        connectionString = 'http://164.76.124.33:1935/live/' + urlParams.streamName + '/playlist.m3u8';
        autoPlay = true;
    } else if(urlParams.fileName) { //if fileName has truthy value
        connectionString = 'http://164.76.124.33:1935/vod/mp4:' + urlParams.fileName + '/playlist.m3u8';
    }
    
    var playerElement = document.getElementById("player-wrapper");

    var player = new Clappr.Player({
        source: connectionString,
        poster: posterImage,
        height: playerHeight,
        width: playerWidth,
        mediacontrol: {seekbar: playerColor, buttons: playerColor},
        autoPlay: autoPlay
    });

    player.attachTo(playerElement);
}
