extends CanvasLayer
const Style = preload("res://ui/style.gd")
var score_label: Label
var hearts: Array[TextureRect] = []
var progress: ProgressBar
var pause_panel: Control
var message: Label
var level

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	var root = Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	var panel = PanelContainer.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	panel.offset_left = 20
	panel.offset_right = -20
	panel.offset_top = 16
	panel.offset_bottom = 82
	panel.add_theme_stylebox_override("panel", Style.box(Color(0.03, 0.14, 0.15, 0.92)))
	root.add_child(panel)
	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 18)
	panel.add_child(row)
	row.add_child(Style.label("JUNGLE JUMP", 21, Style.GOLD))
	score_label = Style.label("0000", 21)
	score_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	row.add_child(score_label)
	for i in range(3):
		var heart = TextureRect.new()
		heart.texture = preload("res://assets/heart.png")
		heart.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		heart.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		heart.custom_minimum_size = Vector2(26, 26)
		row.add_child(heart)
		hearts.append(heart)
	var pause = Style.button("II", toggle_pause)
	pause.custom_minimum_size = Vector2(48, 32)
	row.add_child(pause)
	progress = ProgressBar.new()
	progress.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	progress.offset_left = 24
	progress.offset_right = -24
	progress.offset_top = 90
	progress.offset_bottom = 96
	progress.show_percentage = false
	var track_style = StyleBoxFlat.new()
	track_style.bg_color = Color("#214c48")
	track_style.set_corner_radius_all(3)
	progress.add_theme_stylebox_override("background", track_style)
	var fill_style = StyleBoxFlat.new()
	fill_style.bg_color = Style.GOLD
	fill_style.set_corner_radius_all(3)
	progress.add_theme_stylebox_override("fill", fill_style)
	root.add_child(progress)
	message = Style.label("", 15, Style.GOLD)
	message.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	message.offset_left = 24
	message.offset_top = -38
	root.add_child(message)
	pause_panel = CenterContainer.new()
	pause_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(pause_panel)
	var card = PanelContainer.new()
	card.add_theme_stylebox_override("panel", Style.box())
	pause_panel.add_child(card)
	var column = VBoxContainer.new()
	column.add_theme_constant_override("separation", 12)
	card.add_child(column)
	var title = Style.label("TRAIL PAUSED", 30, Style.GOLD)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(title)
	column.add_child(Style.button("RESUME", toggle_pause))
	column.add_child(Style.button("RETRY LEVEL", GameState.retry_level))
	column.add_child(Style.button("TITLE SCREEN", func(): GameState.show_menu()))
	pause_panel.hide()

func update_score(value):
	score_label.text = "SCORE  %04d" % value

func update_life(value):
	for i in range(3):
		hearts[i].modulate.a = 1.0 if i < value else 0.2

func toggle_pause():
	get_tree().paused = not get_tree().paused
	pause_panel.visible = get_tree().paused
	if pause_panel.visible:
		pause_panel.get_child(0).get_child(0).get_child(1).grab_focus()

func _unhandled_key_input(event):
	if event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			toggle_pause()
		elif event.keycode == KEY_R:
			GameState.retry_level()

