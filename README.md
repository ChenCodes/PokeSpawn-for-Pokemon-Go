# PokeSpawn - Finding Pokemon Has Never Been Easier 

###App description:
PokeSpawn allows you to set the location of various Pokemon that you have captured down on the current location you are standing at. 
You can also search in the searchbar for specific Pokemon. By tapping on the search button, the map will be filtered to show only the pokemon that the user chose. 


###App Features:
**Time stamp**: All pokemon markers / pokestop / pokegym have a timestamp on them that shows how long ago they were dropped down. So if I drop a Charizard down at 12:00pm, at 1:00pm the timestamp on the infowindow of the marker will say "60m ago". 

**Real time updates**: Since our backend is Firebase, we are able to get almost instant feedback of users dropping markers down on the app. During testing, my partner put down a marker in Daly City when I was in San Jose and within 1-2 seconds I could see the marker appear on the screen. 

**Upvote system**: Users can verify the accuracy of a given pokemon marker. If a Pikachu marker was dropped at a certain location and another user walked by that location and managed to catch a Pikachu, they would go on PokeSpawn and press on the marker to upvote the marker. Users cannot upvote markers that they put down themselves, and if they press on a downvote for a marker that they dropped, the marker will be removed from the map. 


![Upvote](https://github.com/ChenCodes/pokespawn-norename/blob/master/upvote.png "Logo Title Text 1")


**Filtering system**: Since Pokemon do not stay in any one area for a very long period of time, it would be unnecessary to keep around "stale markers". Thus, there is a filtering system that allows the user to press a button to find the pokemon markers that were dropped in the last 30 minutes as these will be the most accurate representations of the current location of certain Pokemon. 

**Pokegym / Pokestop**: Future implementations 
Currently, the user has the ability to drop down both a pokegym as well as a pokestop. A future implementation that we want to include would be asking for gym aid. What happens is that each user is assigned a team (Valor, Instinct, Mystic) at the beginning of the app, and when they request help for battle at a gym, users in their vicinity will be notified via remote notification. 

**Trading system**: Future implementations
In the future when Pokemon Go allows trading between users, we want to have a trading system set up so that users can set up their "storage" of pokemon and be able to trade with other users in the vicinity. Users will have a "reputation" which is a rating that tells other users how reliable they are when trading pokemon.


###Development Team
I worked on this project with a fellow senior (Angel Lim) who is also studying EECS at UC Berkeley.

###Motivation behind this project
Pokemon Go was launched pretty recently so we decided that it would be cool if we had an app that lets users input pokemon that they found as well as be able to find Pokemon that they don't have in their Pokedex.

###Q&A Section:
1. When was this app first developed? 
We started developing this app on Tuesday, July 12th and finished our MVP on Thursday evening. 

2. Why is this app not in the Appstore?
There are two main reasons. The first reason is that since another app, Poke Radar was able to hit the Appstore a couple days before we could, they eventually got a lot of users and so we couldn't make it into the Appstore due to our app being labeled a "copycat" app even though we had plenty of features that Poke Radar didn't have. The other reason is that all of our assets were copied from online; we didn't have the time to create 140+ assets that looked like Pokemon but didn't look like Pokemon at the same time. Basically issue 4.1 - Copycat on the Apple Guidelines for submitting apps. 

3. Will you guys continue working on this app?
Possibly. Most likely not, as for now the code that we have in this project is open source for you all to enjoy and modify and hopefully learn more about working with various APIs including GoogleMaps API.





