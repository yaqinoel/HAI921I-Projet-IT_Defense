Cozy Harvest - Construct 3 setup

The images are in the png/ folder of this ZIP.

1. Project properties: Sampling = Nearest, Pixel rounding = On (keeps pixels sharp).
2. For each resizable piece (panel, buttons, inset, tooltip, tabs...), insert a 9-patch object,
   load the PNG in the image editor, then set its properties:
   - Left / Right / Top / Bottom margin: from the table below
   - Edges and Fill: "Tile" for these pieces, so textures repeat cleanly: panel, button_normal, button_hover, button_pressed, button_disabled, scroll_thumb_normal, scroll_thumb_hover, scroll_thumb_pressed
     "Stretch" for the others.
   - Seams: Overlap
3. Fixed-size pieces (checkboxes, radio buttons, toggles, slots, slider grabbers, cursors, close buttons)
   are plain Sprite objects. Use animation frames for states, e.g. checkbox_off / checkbox_on.
4. Mouse cursor: Mouse > Set cursor from sprite. Click points:
     cursor_normal.png: click point x=0, y=0
     cursor_hover.png: click point x=3, y=0
     cursor_pressed.png: click point x=3, y=0
5. Text: use a pixel font (Sprite Font object or a pixel TTF). The kit's font in font/ is a BMFont, which
   Construct doesn't read directly.

9-slice margins in pixels:
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
