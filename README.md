# EMU-Livestream
:clapper: An extensible media player for the web

All subpages are actually the main index.html page with contents of the other html pages injected into them. This way only one base URL is needed, everything else is loaded based on the query strings passed in.

##VOD Menu
Loads the webpage and injects the contents of VODMenu.html into the page.

## Player Page
Either displays a VOD player or a live stream player. Can be given a custom poster image.

##Query String Generator
Loads the query string generator to create URLs for live streams or VODs.

## Query strings

### title
Determines what is displayed in the Title Area of the page.

Usage: http://hounvs.github.io/EMU-Livestream/?title=sample%20title

### desc
Determines what is displayed in the description area of the page.

Usage: http://hounvs.github.io/EMU-Livestream/?desc=sample%20description

### stream
Determines which stream name to load from the streaming server.

Usage: http://hounvs.github.io/EMU-Livestream/?stream=sample

### path/file
Loads a VOD with the given filename from the specified path. Both are required to load a VOD.

Usage: http://hounvs.github.io/EMU-Livestream/?path=VOD&file=sample

### poster
Loads the given image as the poster for the player. Is only used if a player is being shown. These images are loaded from the **images/posters/** subfolder

Usage: http://hounvs.github.io/EMU-Livestream/?path=VOD&file=sample&poster=GoldMed.png

### query
If this has value, the Query String Generator will be loaded.

Usage: http://hounvs.github.io/EMU-Livestream/?query=true
