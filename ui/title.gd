extends Control
const Style = preload("res://ui/style.gd")

func _ready():
	GameState.play_music("Intro Theme")
	var background = TextureRect.new()
	background.texture = preload("res://assets/environment/back.png")
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	var forest = TextureRect.new()
	forest.texture = preload("res://assets/environment/middle.png")
	forest.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	forest.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	forest.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(forest)
	var shade = ColorRect.new()
	shade.color = Color(0.02, 0.12, 0.12, 0.65)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(shade)
	var center = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var panel = PanelContainer.new()
	panel.custom_minimum_size.x = 600
	panel.add_theme_stylebox_override("panel", Style.box(Color(0.035, 0.13, 0.14, 0.94)))
	center.add_child(panel)
	var column = VBoxContainer.new()
	column.add_theme_constant_override("separation", 16)
	panel.add_child(column)
	var kicker = Style.label("A TWO-LEVEL JUNGLE ADVENTURE", 16, Color("#a6d8ba"))
	kicker.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(kicker)
	var heading = "JUNGLE JUMP"
	var subtitle = "Follow the trail. Find the gems. Reach the cabin."
	var button_text = "START ADVENTURE"
	var callback = GameState.start_game
	if GameState.menu_mode == "win":
		heading = "TRAIL COMPLETE!"
		subtitle = "Both trails explored!  Final score: %04d" % GameState.score
		button_text = "PLAY AGAIN"
	elif GameState.menu_mode == "lose":
		heading = "TRY THE TRAIL AGAIN"
		subtitle = "You ran out of hearts. Your next adventure is one jump away."
		button_text = "RETRY LEVEL"
		callback = GameState.retry_level
	var title = Style.label(heading, 40, Style.GOLD)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(title)
	var sub = Style.label(subtitle, 16)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(sub)
	var art = TextureRect.new()
	var texture = AtlasTexture.new()
	texture.atlas = preload("res://assets/player_sheet.png")
	texture.region = Rect2(7 * 32, 0, 32, 32)
	art.texture = texture
	art.custom_minimum_size = Vector2(96, 80)
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	column.add_child(art)
	var start = Style.button(button_text, callback)
	column.add_child(start)
	if GameState.menu_mode != "title":
		column.add_child(Style.button("TITLE SCREEN", func(): GameState.show_menu()))
	var instructions = Style.label("A / D or arrows: move     SPACE: jump / double jump\nW / S or arrows: climb     ESC: pause     R: retry     M: mute", 14, Color("#b7d7ce"))
	instructions.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(instructions)
	var tip = Style.label("Jump on opossums. Collect fruit. Look for the glowing exit.", 14, Style.GOLD)
	tip.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(tip)
	start.grab_focus()

