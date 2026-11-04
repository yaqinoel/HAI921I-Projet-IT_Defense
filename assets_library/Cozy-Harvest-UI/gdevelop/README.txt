Cozy Harvest - GDevelop setup

The images are in the png/ folder of this ZIP.

1. Project properties: Scale mode = Nearest (no antialiasing), and turn on "Round pixels when rendering".
2. For each resizable piece (panel, buttons, inset, tooltip, tabs...), add a "Panel Sprite (9-patch)" object,
   choose the PNG, and enter the Top / Bottom / Left / Right margins from the table below.
   Tick "Repeat borders and center textures" for these pieces, so textures repeat cleanly:
   panel, button_normal, button_hover, button_pressed, button_disabled, scroll_thumb_normal, scroll_thumb_hover, scroll_thumb_pressed
3. Fixed-size pieces (checkboxes, radio buttons, toggles, slots, slider grabbers, close buttons) are Sprite objects;
   add the states as animations (e.g. checkbox_off / checkbox_on, button_normal / button_hover / button_pressed).
4. Text: use a Bitmap Text object with the kit's font in font/ (font.fnt + font.png, BMFont format).
5. Mouse cursor: hide the system cursor (Hide the cursor action) and draw cursor_normal.png at the mouse position.
   Click points (subtract these from the mouse position):
     cursor_normal.png: click point x=0, y=0
     cursor_hover.png: click point x=3, y=0
     cursor_pressed.png: click point x=3, y=0

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
