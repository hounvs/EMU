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
    
    // Check if stream name or file path/name are defined
    if(urlParams.stream) {   // if stream has truthy value
        connectionString = 'http://164.76.124.33:1935/live/' + urlParams.stream + '/playlist.m3u8';
        autoPlay = true;
    } else if(urlParams.path && urlParams.file) { // if path and file have truthy values
        connectionString = 'http://164.76.124.33:1935/' + urlParams.path + '/mp4:' + urlParams.file + '/playlist.m3u8';
    }
    
    // Get player wrapper
    var playerElement = document.getElementById("player-wrapper");
    
    // if connectionStringhas truthy value
    if(connectionString) {
        // Build the player
        var player = new Clappr.Player({
            source: connectionString,
            poster: posterImage,
            height: playerHeight,
            width: playerWidth,
            mediacontrol: {seekbar: playerColor, buttons: playerColor},
            autoPlay: autoPlay
        });
        
        // Populate player container
        player.attachTo(playerElement);
    } else {    // show the menu
        // TODO: Add menu and hide playerElement
        $(playerElement).hide();
    }
}
