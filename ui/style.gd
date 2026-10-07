extends RefCounted
const GOLD = Color("#ffe49a")
const INK = Color("#102d30")
const FONT = preload("res://assets/Kenney Thick.ttf")

static func label(text_value, size_value = 24, color_value = Color.WHITE):
	var node = Label.new()
	node.text = text_value
	node.add_theme_font_override("font", FONT)
	node.add_theme_font_size_override("font_size", size_value)
	node.add_theme_color_override("font_color", color_value)
	node.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.4))
	node.add_theme_constant_override("shadow_offset_y", 2)
	return node

static func box(color_value = Color("#153b3e")):
	var style = StyleBoxFlat.new()
	style.bg_color = color_value
	style.set_corner_radius_all(14)
	style.set_content_margin_all(18)
	style.border_color = Color("#44746a")
	style.set_border_width_all(2)
	return style

static func button(text_value, action):
	var node = Button.new()
	node.text = text_value
	node.custom_minimum_size = Vector2(280, 52)
	node.add_theme_font_override("font", FONT)
	node.add_theme_font_size_override("font_size", 22)
	node.add_theme_color_override("font_color", INK)
	node.add_theme_color_override("font_hover_color", INK)
	node.add_theme_color_override("font_focus_color", INK)
	node.add_theme_stylebox_override("normal", box(GOLD))
	node.add_theme_stylebox_override("hover", box(Color("#fff3c9")))
	node.add_theme_stylebox_override("pressed", box(Color("#d8b66c")))
	node.add_theme_stylebox_override("focus", box(Color("#fff3c9")))
	node.pressed.connect(action)
	return node

