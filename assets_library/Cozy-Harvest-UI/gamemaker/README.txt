Cozy Harvest - GameMaker setup (GameMaker 2.3.2 or newer)

1. Drag all PNGs from the sprites folder into GameMaker's Asset Browser. Each becomes a sprite named
   after its file (spr_panel, spr_button_normal, ...). Keep those names: the script finds sprites by name.
2. Create a Script asset, replace its contents with scr_bevelsmith_cozy_harvest.gml, and call bevelsmith_cozy_harvest_setup() once at game start
   (for example in the Create event of a controller object in your first room).
3. Draw pieces at any size with draw_sprite_stretched(spr_panel, 0, x, y, width, height).
   Textured pieces repeat their middle instead of stretching, so patterns and rivets stay crisp.
4. Keep pixels sharp: Game Options > (your platform) > Graphics > untick "Interpolate colours between pixels".
5. Mouse cursor: window_set_cursor(cr_none); cursor_sprite = spr_cursor_normal;
   Switch to spr_cursor_hover over buttons and spr_cursor_pressed while the mouse button is down.
   The script sets each cursor's origin to its click point:
     spr_cursor_normal: click point x=0, y=0
     spr_cursor_hover: click point x=3, y=0
     spr_cursor_pressed: click point x=3, y=0

If a build says a sprite is "not found": newer GameMaker versions can remove assets that are only looked
up by name. Untick Game Options > General > "Automatically remove unused assets when compiling", or give
the kit's sprites the asset tag "keep".

Prefer the IDE? Open a sprite, tick Nine Slice and type these margins (Tile modes: "repeat" pieces use Repeat):
  piece                     size   left  top  right  bottom  centre
  panel.png                 70x72  5     5    5      7       repeat
  button_normal.png         20x24  4     6    4      6       repeat
  button_hover.png          20x24  4     6    4      6       repeat
  button_pressed.png        20x24  4     6    4      6       repeat
  button_disabled.png       20x24  4     6    4      6       repeat
  inset.png                 18x18  3     3    3      3       stretch
  bar_fill.png              16x4   2     0    2      0       stretch
  tab_selected.png          24x16  6     8    6      0       stretch
  tab_unselected.png        24x16  6     8    6      0       stretch
  tab_hover.png             24x16  6     8    6      0       stretch
  tab_disabled.png          24x16  6     8    6      0       stretch
  tooltip.png               21x21  4     4    5      5       stretch
  scroll_thumb_normal.png   18x18  3     3    3      3       repeat
  scroll_thumb_hover.png    18x18  3     3    3      3       repeat
  scroll_thumb_pressed.png  18x18  3     3    3      3       repeat
  separator_h.png           8x2    0     0    0      0       stretch
  separator_v.png           2x8    0     0    0      0       stretch
