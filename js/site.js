// Grabs the query strings and puts them into urlParams
var urlParams;

(function () {
    window.onpopstate = function () {
        var match,
            pl = /\+/g,  // Regex for replacing addition symbol with a space
            search = /([^&=]+)=?([^&]*)/g,
            decode = function (s) {
                return decodeURIComponent(s.replace(pl, " "));
            },
            query = window.location.search.substring(1);

        urlParams = {};
        while (match = search.exec(query)) {
            urlParams[decode(match[1])] = decode(match[2]);
        }
    };
    window.onpopstate();
}());

function loadPlayer(newPosterImage) {
    // Defaults
    var connectionString = '';
    var posterImage = newPosterImage;
    var playerColor = "#006234";
    var playerHeight = 480;
    var playerWidth = 720;
    var autoPlay = false;

    // Check if stream name or file path/name are defined
    if (urlParams.stream) {   // if stream has truthy value
        // http://164.76.124.68/stream/index.html?stream=test
        connectionString = 'http://164.76.124.33:1935/live/' + urlParams.stream + '/playlist.m3u8';
        autoPlay = true;
    } else if (urlParams.path && urlParams.file) { // if path and file have truthy values
        // http://164.76.124.68/stream/index.html?path=vod&file=sample
        connectionString = 'http://164.76.124.33:1935/' + urlParams.path + '/mp4:' + urlParams.file + '/playlist.m3u8';
    }
    
    // If posterImage didn't get a valid value, assign default
    if(!posterImage) {
        posterImage = 'images/emu-logo.jpg';
    }
    
    // If title is set in ULR, change title
    if(urlParams.title) {
        $(document.getElementById("title")).html(urlParams.title);
    }
    
    // If description is set in URL, change description
    if(urlParams.desc){
        $(document.getElementById("description")).html(urlParams.desc);
    }

    // Get player and menu wrappers
    var playerElement = document.getElementById("player");

    // if connectionStringhas truthy value
    if (connectionString) {
        $(document.getElementById("header")).show();
        $(document.getElementById("player-wrapper")).show();
        $(document.getElementById("menu-wrapper")).hide();
        
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
        $(document.getElementById("header")).hide();
        $(document.getElementById("player-wrapper")).hide();
        $(document.getElementById("menu-wrapper")).show();
    }
}

function parseMenu() {
    $("#queryString").val(
        "?title=" + encodeURIComponent($("#title-text").val()) +
        "&desc=" + encodeURIComponent($("#description-text").val()) +
        "&stream=" + encodeURIComponent($('#stream').val()) +
        "&path=" + encodeURIComponent($('#path').val()) +
        "&file=" + encodeURIComponent($('#file').val())
    );
}