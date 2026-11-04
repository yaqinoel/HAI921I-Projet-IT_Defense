Cozy Harvest - Godot 4 setup

ui_kit/ is a ready Godot 4 theme. Copy the ui_kit folder into your project, then either
  - Project Settings > GUI > Theme > Custom: ui_kit/theme.tres (whole project), or
  - set it as the Theme of any Control (that node and its children).
Also set Project Settings > Rendering > Textures > Default Texture Filter to Nearest.
Includes a matching pixel font (font.fnt), drawn at 7px. Pixel fonts are only crisp at whole
multiples of that size: if you override font sizes, use 7, 14, 21, 28... (in-between sizes look lumpy).

../godot_demo/ is a small Godot 4.7 project showing the theme. Open project.godot in Godot and press Play.