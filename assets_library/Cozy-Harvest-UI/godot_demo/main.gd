extends Control

# Uses the kit's mouse cursors: the pointer, the cursor over clickable things, and the one shown while the mouse
# button is held on them. Cursors are drawn by the OS at their own size, so they are scaled up to match how big
# the game's pixels are on screen.
const KIT := "res://ui_kit/"

var _hover: Texture2D
var _pressed: Texture2D
var _hover_spot: Vector2
var _pressed_spot: Vector2

func _ready() -> void:
	# The pixel size on screen changes when the window is resized or goes fullscreen: rescale the cursors then too.
	get_window().size_changed.connect(_apply_cursors)
	_apply_cursors()

func _apply_cursors() -> void:
	var factor := maxi(1, int(get_window().size.y / get_viewport_rect().size.y))
	Input.set_custom_mouse_cursor(_scaled(KIT + "cursor_normal.png", factor), Input.CURSOR_ARROW, Vector2(0, 0) * factor)
	_hover = _scaled(KIT + "cursor_hover.png", factor)
	_pressed = _scaled(KIT + "cursor_pressed.png", factor)
	_hover_spot = Vector2(3, 0) * factor
	_pressed_spot = Vector2(3, 0) * factor
	Input.set_custom_mouse_cursor(_hover, Input.CURSOR_POINTING_HAND, _hover_spot)

# Swap to the "pressed" cursor while the left button is held (buttons use the pointing-hand cursor shape).
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			Input.set_custom_mouse_cursor(_pressed, Input.CURSOR_POINTING_HAND, _pressed_spot)
		else:
			Input.set_custom_mouse_cursor(_hover, Input.CURSOR_POINTING_HAND, _hover_spot)

# Give the cursor textures back before the engine shuts down (avoids "leaked at exit" warnings).
func _exit_tree() -> void:
	Input.set_custom_mouse_cursor(null, Input.CURSOR_ARROW)
	Input.set_custom_mouse_cursor(null, Input.CURSOR_POINTING_HAND)

func _scaled(path: String, factor: int) -> Texture2D:
	var image := (load(path) as Texture2D).get_image()
	image.resize(image.get_width() * factor, image.get_height() * factor, Image.INTERPOLATE_NEAREST)
	return ImageTexture.create_from_image(image)
