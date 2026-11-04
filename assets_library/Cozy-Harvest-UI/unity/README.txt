Cozy Harvest - Unity setup (Unity 2019.4 or newer)

1. Copy the "Bevelsmith" folder into your project's Assets folder. If it's already there from another
   kit, merge it (replace the files when asked: Editor/BevelsmithImporter.cs is the same in every kit).
   Unity imports the PNGs in Bevelsmith/Cozy Harvest/Sprites as pixel-perfect sprites with their 9-slice
   borders already set. If they look blurry or have no borders, run Tools > Bevelsmith > Reimport UI kits.

2. Use them in the UI (uGUI / Canvas):
   - Panel: add UI > Image, Source Image = panel, Image Type = Tiled (the texture repeats instead of stretching).
   - Button: Image = button_normal (Image Type = Tiled), Transition = Sprite Swap:
     Highlighted = button_hover, Pressed = button_pressed, Selected = button_hover, Disabled = button_disabled.
   - Toggle: Background = checkbox_off, Checkmark = checkbox_on (or radio_off / radio_on).
   - Slider: Background = inset, Fill = bar_fill, Handle = slider_grabber_normal
     (Transition = Sprite Swap, Highlighted = slider_grabber_hover).
   - Scrollbar: Background = inset, Handle = scroll_thumb_normal (Sprite Swap: scroll_thumb_hover / _pressed).
   - Tabs: tab_selected, tab_unselected, tab_hover, tab_disabled. Tooltips: tooltip. Inventory: slot.
   Use Image Type = Tiled for these pieces so textures and ornaments repeat cleanly:
     panel, button_normal, button_hover, button_pressed, button_disabled, scroll_thumb_normal, scroll_thumb_hover, scroll_thumb_pressed
   All other resizable pieces: Image Type = Sliced.

3. Pixel size: this kit was exported at 1x. To draw borders bigger without re-exporting, lower the Image's
   "Pixels Per Unit Multiplier" (0.5 = twice as big, 0.25 = four times). Keep the Canvas Scaler at whole-number
   scales so pixels stay square.

4. Mouse cursor (the PNGs are imported as cursors):
     Cursor.SetCursor(cursorNormalTexture, new Vector2(x, y), CursorMode.Auto);
   Swap to cursor_hover over buttons and cursor_pressed while the mouse button is down. Click points:
     cursor_normal.png: click point x=0, y=0
     cursor_hover.png: click point x=3, y=0
     cursor_pressed.png: click point x=3, y=0

5. Text: Unity's UI text is smooth by default. For crisp text use a pixel font; the kit's own font is in the
   font/ folder of this ZIP as a BMFont (font.fnt + font.png).

9-slice margins in pixels (Unity reads these from bevelsmith_slices.json automatically):
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
