Cozy Harvest - generated with Bevelsmith

png/
  One PNG per UI piece. nine_slice.json lists the margins (in pixels) that must not stretch:
  set them as the 9-slice / nine-patch margins in your engine so borders stay crisp at any size.
  Use nearest-neighbour (no filtering) texture sampling to keep pixels sharp.

font/
  The kit's pixel font as a BMFont (font.fnt + font.png). White, so engines can tint it.

godot/  (Godot 4)
  A ready theme (.tres) with the pixel font, plus a demo project (godot_demo/). See godot/README.txt.

unity/  (Unity)
  Sprites with 9-slice borders set automatically by an editor script. See unity/README.txt.

gamemaker/  (GameMaker)
  Sprites plus a script that sets their nine-slice margins and cursor origins. See gamemaker/README.txt.

rpgmaker/  (RPG Maker MZ / MV)
  A window skin (img/system/Window.png). See rpgmaker/README.txt.

construct3/  (Construct 3)
  9-patch setup guide with every margin. See construct3/README.txt.

gdevelop/  (GDevelop)
  Panel Sprite setup guide with every margin. See gdevelop/README.txt.

aseprite/  (Aseprite (editable))
  The whole kit as one .aseprite file to polish by hand: every piece a named slice with its 9-slice centre. See aseprite/README.txt.

other-engines/  (Other engines)
  Notes for Defold, Phaser, LÖVE, MonoGame and Unreal. See other-engines/README.txt.