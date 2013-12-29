# Roku channel for ZDF Mediathek #


Why?
----
I often find myself watching ZDF Mediathek's criminal shows. Before buying a Roku, I always watched
them on my laptop. With a spanking new Roku in hand, it seemed obvious that I should be watching
them on an actual TV and thus the idea to hack up this channel was conceived.

What?
-----
As of now, I only plan on making the 'Sendung Verpasst' section of the Mediathek work. I don't plan
on publishing the channel (probably a boatload of legal reasons in the way) but if you want it,
clone this repo and side load it onto your Roku (only tested on Roku 3). 

Status:
-------
It's still a work in progress but it dynamically loads the content of the past seven days and
serves up the clips. It doesn't have a pretty detail screen yet and doesn't give any hint if a
clip isn't available (urls missing from xml response). 


### Notes: ###
- The code is heavily based on Roku's Videoplayer sample which is published under
http://creativecommons.org/licenses/by-nc-nd/3.0/
- ...

### Screenshots ###
<img src="screenshots/SendungVerpasstOverview.jpg" alt="Sendung Verpasst Overview Screen" style="width: 200px;"/>
<img src="screenshots/SendungVerpasstDay.jpg" alt="Sendung Verpasst Day Screen" style="width: 200px;"/>
<img src="screenshots/SendungVerpasstDetail.jpg" alt="Sendung Verpasst Detail Screen" style="width: 200px;"/>