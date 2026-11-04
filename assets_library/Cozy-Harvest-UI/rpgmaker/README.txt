Cozy Harvest - RPG Maker MZ / MV window skin

1. In your project folder, back up img/system/Window.png, then replace it with the Window.png from this folder.
   (Or keep both and switch skins with a plugin.)
2. Database > System 1 > Window Color: set it to 0, 0, 0 so the skin's own colours show unchanged.
3. Test play. Windows, the selection cursor, scroll arrows, the "more text" sign and the text colours
   (\C[0]..\C[31], HP/MP/TP gauges) all come from this one image.

Notes:
- RPG Maker draws window backgrounds 25% see-through by default (back opacity 192). Plugins can make them solid.
- Text colour 0 is the kit's label colour; the other \C[n] colours keep RPG Maker's usual meanings, adjusted to stay
  readable on this background.
- RPG Maker outlines all text in dark grey, which can look heavy on a light window like this one. Many message plugins let you change or remove the outline.

The other kit pieces (buttons, bars, slots...) are in the png/ folder for use with plugins that draw custom UI.
Their 9-slice margins at 1x:
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
