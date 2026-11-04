/// Bevelsmith UI kit "Cozy Harvest" for GameMaker 2.3.2 or newer.
/// Sets the nine-slice margins and the cursor click points on the kit's sprites.
/// Call bevelsmith_cozy_harvest_setup() once when the game starts, e.g. in the Create event of a controller object.
/// Then draw any piece at any size: draw_sprite_stretched(spr_panel, 0, x, y, width, height);
function bevelsmith_cozy_harvest_setup() {
	// sprite, left, top, right, bottom, repeat top/bottom edges, repeat left/right edges, repeat centre
	var _pieces = [
		["spr_panel", 5, 5, 5, 7, true, true, true],
		["spr_button_normal", 4, 6, 4, 6, true, true, true],
		["spr_button_hover", 4, 6, 4, 6, true, true, true],
		["spr_button_pressed", 4, 6, 4, 6, true, true, true],
		["spr_button_disabled", 4, 6, 4, 6, true, true, true],
		["spr_inset", 3, 3, 3, 3, false, false, false],
		["spr_bar_fill", 2, 0, 2, 0, false, false, false],
		["spr_tab_selected", 6, 8, 6, 0, false, false, false],
		["spr_tab_unselected", 6, 8, 6, 0, false, false, false],
		["spr_tab_hover", 6, 8, 6, 0, false, false, false],
		["spr_tab_disabled", 6, 8, 6, 0, false, false, false],
		["spr_tooltip", 4, 4, 5, 5, false, false, false],
		["spr_scroll_thumb_normal", 3, 3, 3, 3, true, true, true],
		["spr_scroll_thumb_hover", 3, 3, 3, 3, true, true, true],
		["spr_scroll_thumb_pressed", 3, 3, 3, 3, true, true, true],
		["spr_separator_h", 0, 0, 0, 0, true, false, false],
		["spr_separator_v", 0, 0, 0, 0, false, true, false],
	];
	for (var _i = 0; _i < array_length(_pieces); _i++) {
		var _p = _pieces[_i];
		if (asset_get_type(_p[0]) != asset_sprite) {
			show_debug_message("Bevelsmith: sprite " + _p[0] + " not found. Import it from the kit's sprites folder.");
			continue;
		}
		var _spr = asset_get_index(_p[0]);
		var _ns = sprite_nineslice_create();
		_ns.enabled = true;
		_ns.left = _p[1];
		_ns.top = _p[2];
		_ns.right = _p[3];
		_ns.bottom = _p[4];
		_ns.tilemode[nineslice_top] = _p[5] ? nineslice_repeat : nineslice_stretch;
		_ns.tilemode[nineslice_bottom] = _p[5] ? nineslice_repeat : nineslice_stretch;
		_ns.tilemode[nineslice_left] = _p[6] ? nineslice_repeat : nineslice_stretch;
		_ns.tilemode[nineslice_right] = _p[6] ? nineslice_repeat : nineslice_stretch;
		_ns.tilemode[nineslice_centre] = _p[7] ? nineslice_repeat : nineslice_stretch;
		sprite_set_nineslice(_spr, _ns);
	}

	// Mouse cursors: the sprite origin is the click point.
	var _cursors = [
		["spr_cursor_normal", 0, 0],
		["spr_cursor_hover", 3, 0],
		["spr_cursor_pressed", 3, 0],
	];
	for (var _i = 0; _i < array_length(_cursors); _i++) {
		var _c = _cursors[_i];
		if (asset_get_type(_c[0]) == asset_sprite) sprite_set_offset(asset_get_index(_c[0]), _c[1], _c[2]);
	}
}
