Cozy Harvest - other engines

Everything is in png/: one PNG per piece, plus nine_slice.json with each piece's size, 9-slice margins
(left, top, right, bottom in pixels), whether its middle should repeat ("tile_h", "tile_v", "tile_centre")
and the mouse cursors' click points. The kit's pixel font is in font/ as a BMFont (font.fnt + font.png).
Always draw with nearest-neighbour filtering so pixels stay sharp.

Defold
  GUI: add the PNGs to an atlas, use Box nodes, and set Slice9 to (left, top, right, bottom).
  Sprites: set slice9 in the sprite component. In game.project set the texture filters to nearest.

Phaser 3.60+
  new Phaser.Game({ pixelArt: true, ... })
  this.add.nineslice(x, y, 'panel', undefined, width, height, 5, 5, 5, 7);
  (Phaser's order is left, right, top, bottom.) Fonts: this.load.bitmapFont('kit', 'font.png', 'font.fnt').

LÖVE (love2d)
  love.graphics.setDefaultFilter('nearest', 'nearest') before loading images.
  No built-in 9-slice: draw the nine parts with quads. A small helper (stretches the middle):

    local function nineslice(img, l, t, r, b)
      local w, h = img:getDimensions()
      local xs, ws = {0, l, w - r}, {l, w - l - r, r}
      local ys, hs = {0, t, h - b}, {t, h - t - b, b}
      local quads = {}
      for row = 1, 3 do for col = 1, 3 do
        quads[#quads + 1] = love.graphics.newQuad(xs[col], ys[row], ws[col], hs[row], w, h)
      end end
      return function(x, y, dw, dh)
        local cw, ch = {l, dw - l - r, r}, {t, dh - t - b, b}
        local dx, dy = {x, x + l, x + dw - r}, {y, y + t, y + dh - b}
        for row = 1, 3 do for col = 1, 3 do
          local i = (row - 1) * 3 + col
          love.graphics.draw(img, quads[i], dx[col], dy[row], 0, cw[col] / ws[col], ch[row] / hs[row])
        end end
      end
    end

    local drawPanel = nineslice(love.graphics.newImage('panel.png'), 5, 5, 5, 7)
    -- in love.draw(): drawPanel(10, 10, 200, 120)
  Fonts: love.graphics.newFont('font.fnt') reads BMFont files.

MonoGame / FNA
  Use SamplerState.PointClamp and draw the nine source rectangles from the margins with SpriteBatch
  (corners at their own size, edges and middle stretched to fill the target rectangle).

Unreal Engine (UMG)
  Import the PNGs with Texture Group = UI, Compression = UserInterface2D, Filter = Nearest.
  In an Image or Border brush set Draw As = Box and Margin to the margins divided by the image size
  (they're fractions, 0..1). Example, panel (70x72): Left 0.0714, Top 0.0694, Right 0.0714, Bottom 0.0972.

Mouse cursor click points:
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
