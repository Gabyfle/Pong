# Pong
 A Pong game created in Lua with the **LÖVE2D** engine!
 
<p align="center">
  <img width="300" height="300" src="https://raw.githubusercontent.com/Gabyfle/Pong/master/PongPing.png">
</p>

## Requirements
* **[LÖVE2D](https://love2d.org/)**
* `LuaSocket` available on `LuaRocks`
* Two devices to play with someone else!

## How to play
* Install **[LÖVE2D](https://love2d.org/)**
* Launch a server on a device and get the IP / PORT of it
* Configure your client (`Pong/client/config.lua`) to connect to your server
* Tell a friend to join your server 
* Connect to your server by clicking on `launch.bat` in `Pong/client` and...
* **Enjoy** playing this *beautiful*, *amazing* and *stunning* game !

## How does it works
### Protocol
This protocol is based on UDP to ensure a minimum efficiency
  * #### General operation
    * On the first player connexion, we generate a random string that will be his authentification key
    * Each time the client send some data, he send his authentification key with it so that the server can check that it's a current player
    * Right after the last data receive from a particular client, we start a timer. If this timer ends up before a new data receive from this client, then we consider that he timed out and we end the connexion

  * #### Limitations
    * There is no checksum to check if the packet is corrupted
    * The random string is not efficient to ensure a basic security

### Server
* We firstly create a server which is waiting for 2 clients to start a game
* When two clients are connected, the game is started by the server
* Each time a client moves, he sends a JSON string to the server that contains data of his movements
* On serverside, the angle is calculated depending on whether or not the ball collided something
* Trajectory is calculated on both sides, which means that only the angles are calculated serverside which is less heavy for the network
* Once the ball collided something, the server calculates the angle and send it to the player

### Client
* We initialize the client by trying to connect to the given IP in the `config` file
  * If we do not receive an answer from the server within a certain delay, then we consider the server as down
* Each time we move we send movement data to server

## Credits
### Code
* **<ins>Author</ins>** : **Gabriel Santamaria**
### Fonts
* **<ins>Font name</ins>** : [DS-Digital](https://www.dafont.com/fr/ds-digital.font) (Normal, **Bold**, *Italic*, ***Bold Italic***), *Version 1.0*
    * **<ins>Author</ins>** : **Dusit Supasawat**
