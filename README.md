# ACSIM
A Micropolis clone. This is mainly a hobby project which helps me to learn how to do new things.

Uses placeholder graphics from Micropolis during the prototype phase, until I can make my own graphics:
https://github.com/bsimser/Micropolis/blob/develop/Micropolis/Assets/Micropolis/Resources/Tilesets/classic95/tiles.png

Made using Godot 4 game engine, Vulkan renderer.

Features implemented as of 19.2.2023:
- Mapgen based on provided .png image
- Map sizes 128x128 - 4096x4096, one tile is ~3x3 meters
- Procedural forest generation with noise map
- Chunk rendering to support larger maps
- Camera pan, zoom in, and out with mouse
- Camera rotation with arrow keys, in 45 degree steps, or stepless
- Minimap: move camera with mouse clicks
- Minimap: show the camera view with a rectangle
- Layers: show the parcel layers
- Basic mainmenu with new game, resume and exit working

Example screenshots:

Main menu:
![acsim_2023-2-16_22_49-20](https://user-images.githubusercontent.com/107028220/219901492-db5a14c3-eebb-4616-935a-93be6674e58e.png)

Game view:
<img width="1290" alt="game_view01" src="https://user-images.githubusercontent.com/107028220/219068072-9dd38335-ca42-4109-820a-b3bd137ef22e.png">

With a rotated camera (and a rotated camera box in minimap):
<img width="1290" alt="game_view02" src="https://user-images.githubusercontent.com/107028220/219068082-e325cb84-ecbf-4f21-a387-3899761fc25d.png">
