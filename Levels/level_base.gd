extends Node
signal score_changed(value)
@export var level_number = 1
const ITEM = preload("res://items/item.tscn")
const ENEMY = preload("res://enemies/enemy.tscn")
const PLATFORM = preload("res://objects/moving_platform.tscn")
const HUD = preload("res://ui/hud.gd")
const PROPS = preload("res://assets/environment/props.png")
var hud
var score = 0
var finishing = false
var checkpoint = Vector2(64, 200)
var checkpoint_active = false
var ladder_rects: Array[Rect2] = []
var goal_position = Vector2.ZERO
var scenery: Node2D
var exit_glow: Polygon2D
var checkpoint_marker: Sprite2D

func _ready():
	GameState.current_level = level_number
	score = GameState.score
	scenery = Node2D.new()
	scenery.name = "Scenery"
	add_child(scenery)
	create_background()
	create_scenery()
	hud = CanvasLayer.new()
	hud.set_script(HUD)
	add_child(hud)
	hud.level = self
	$Player.life_changed.connect(hud.update_life)
	$Player.died.connect(_on_player_died)
	$Player.reset($SpawnPoint.position)
	checkpoint = $SpawnPoint.position
	$Player/Camera2D.zoom = Vector2(2.5, 2.5)
	$Player/Camera2D.position = Vector2(0, -44)
	$Player/Camera2D.position_smoothing_enabled = true
	$Player/Camera2D.position_smoothing_speed = 7.0
	var bounds = $World.get_used_rect()
	$Player/Camera2D.limit_left = 0
	$Player/Camera2D.limit_right = bounds.end.x * 16
	$Player/Camera2D.limit_top = -64
	$Player/Camera2D.limit_bottom = 304
	$Player/Camera2D.reset_smoothing()
	$Items.hide()
	spawn_items()
	spawn_enemies()
	create_platforms()
	hud.update_score(score)
	hud.update_life(3)
	GameState.play_music("Grasslands Theme")

func create_background():
	for data in [["back", 0.18, -20], ["middle", 0.40, -15]]:
		var parallax = Parallax2D.new()
		parallax.name = data[0].capitalize()
		parallax.scroll_scale = Vector2(data[1], 1)
		parallax.repeat_size = Vector2((384 if data[0] == "back" else 176) * 8, 0)
		parallax.repeat_times = 5
		parallax.z_index = data[2]
		var sprite = Sprite2D.new()
		sprite.texture = load("res://assets/environment/%s.png" % data[0])
		sprite.centered = false
		sprite.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
		sprite.region_enabled = true
		sprite.region_rect = Rect2(0, 0, sprite.texture.get_width() * 8, sprite.texture.get_height())
		sprite.position = Vector2(-sprite.texture.get_width() * 4, -64 if data[0] == "back" else 16)
		if level_number == 2:
			sprite.modulate = Color("#bdc3ea")
		parallax.add_child(sprite)
		add_child(parallax)

func ground_height(x):
	var cell_x = int(x / 16)
	for y in range(5, 20):
		if $World.get_cell_source_id(0, Vector2i(cell_x, y)) != -1:
			return float(y * 16)
	return 208.0

func prop(node_name, x, region, height = -1.0):
	var sprite = Sprite2D.new()
	sprite.name = node_name
	sprite.texture = PROPS
	sprite.region_enabled = true
	sprite.region_rect = region
	sprite.position = Vector2(x, (ground_height(x) if height < 0 else height) - region.size.y / 2)
	sprite.z_index = -1
	scenery.add_child(sprite)
	return sprite

func create_scenery():
	var length = 2400 if level_number == 1 else 2720
	for x in range(240, length - 160, 300):
		prop("Tree", x, Rect2(112, 32, 128, 96))
	for x in range(340, length - 160, 240):
		prop("Crate", x, Rect2(16, 176, 32, 32))
	for x in range(430, length - 160, 280):
		prop("Rock", x, Rect2(16, 112, 32, 16))
	for x in range(150, length - 120, 190):
		prop("Bush", x, Rect2(240, 96, 48, 32))
	goal_position = Vector2(length - 80, ground_height(length - 80))
	prop("Cabin", goal_position.x + 5, Rect2(304, 16, 112, 112), goal_position.y)
	exit_glow = Polygon2D.new()
	exit_glow.polygon = PackedVector2Array([Vector2(-14, 0), Vector2(14, 0), Vector2(14, -40), Vector2(-14, -40)])
	exit_glow.color = Color(1, 0.85, 0.4, 0.25)
	exit_glow.position = goal_position
	scenery.add_child(exit_glow)
	world_label("EXIT >", goal_position + Vector2(-28, -135))
	world_label("SUNLIT SHORES" if level_number == 1 else "TWILIGHT CANOPY", Vector2(32, 102))
	world_label("SPACE: jump twice", Vector2(32, 124))
	checkpoint_marker = prop("Checkpoint", 1216, Rect2(368, 144, 32, 32))
	world_label("CHECKPOINT", Vector2(1180, ground_height(1216) - 58))

func world_label(text, location):
	var label = Label.new()
	label.text = text
	label.position = location
	label.add_theme_font_size_override("font_size", 9)
	label.add_theme_color_override("font_color", Color("#fff0bb"))
	label.add_theme_color_override("font_shadow_color", Color("#153b3e"))
	label.add_theme_constant_override("shadow_offset_y", 1)
	scenery.add_child(label)

func spawn_items():
	for cell in $Items.get_used_cells(0):
		var data = $Items.get_cell_tile_data(0, cell)
		if data == null:
			continue
		var kind = data.get_custom_data("type")
		if kind not in ["cherry", "gem"]:
			continue
		var item = ITEM.instantiate()
		add_child(item)
		item.init(kind, $Items.map_to_local(cell))
		item.add_to_group("collectibles")
		item.picked_up.connect(_on_item_picked_up)

func spawn_enemies():
	var places = [440, 1000, 1480, 2050] if level_number == 1 else [360, 850, 1390, 1870, 2340]
	for x in places:
		var enemy = ENEMY.instantiate()
		enemy.position = Vector2(x, ground_height(x) - 2)
		enemy.patrol_distance = 34
		enemy.speed = 32 if level_number == 1 else 42
		add_child(enemy)
		enemy.defeated.connect(func(): add_score(50))

func create_platforms():
	var moving = PLATFORM.instantiate()
	moving.position = Vector2(760, 194) if level_number == 1 else Vector2(630, 194)
	moving.offset = Vector2(100, 0)
	moving.duration = 4.5
	add_child(moving)
	var lift = PLATFORM.instantiate()
	lift.position = Vector2(1660, 186)
	lift.offset = Vector2(0, -85)
	lift.duration = 5.0
	add_child(lift)
	create_ladder(Vector2(1128, 112), 6)
	create_ladder(Vector2(1992, 80), 8)
	for pos in [Vector2(1152, 112), Vector2(2020, 80)]:
		var perch = PLATFORM.instantiate()
		perch.position = pos
		perch.offset = Vector2.ZERO
		add_child(perch)
		var item = ITEM.instantiate()
		add_child(item)
		item.init("gem", pos + Vector2(10, -22))
		item.add_to_group("collectibles")
		item.picked_up.connect(_on_item_picked_up)

func create_ladder(top, count):
	ladder_rects.append(Rect2(top - Vector2(7, 24), Vector2(14, count * 16 + 36)))
	for i in range(count):
		var sprite = Sprite2D.new()
		sprite.texture = preload("res://assets/environment/tileset.png")
		sprite.region_enabled = true
		sprite.region_rect = Rect2(112, 160, 16, 16)
		sprite.position = top + Vector2(0, i * 16 + 8)
		sprite.z_index = -1
		scenery.add_child(sprite)
	world_label("W / S: climb", top + Vector2(-26, count * 16 + 4))

func _physics_process(_delta):
	if finishing:
		return
	var player = $Player
	player.is_on_ladder = false
	for rect in ladder_rects:
		if rect.has_point(player.position - Vector2(0, 8)):
			player.is_on_ladder = true
	hud.progress.value = clampf(player.position.x / goal_position.x * 100, 0, 100)
	var subtitle = "01  SUNLIT SHORES" if level_number == 1 else "02  TWILIGHT CANOPY"
	hud.message.text = subtitle + "     |     Find the cabin exit     |     ESC pause   M mute"
	exit_glow.modulate.a = 0.65 + sin(Time.get_ticks_msec() * 0.004) * 0.3
	if not checkpoint_active and absf(player.position.x - 1216) < 28:
		checkpoint_active = true
		checkpoint = Vector2(1216, ground_height(1216) - 5)
		checkpoint_marker.modulate = Color("#ffe49a")
		GameState.sound("pickup2")
	if player.position.y > 400:
		player.invulnerability = 0
		player.hurt()
		if player.life > 0:
			player.position = checkpoint
			player.velocity = Vector2.ZERO
			player.hurt_time = 0
			player.change_state(player.IDLE)
			player.get_node("Camera2D").reset_smoothing()
	player.position.x = clampf(player.position.x, 8, goal_position.x + 44)
	if player.state != player.DEAD and player.position.x >= goal_position.x - 22 and absf(player.position.y - goal_position.y) < 38:
		complete_level()

func complete_level():
	if finishing:
		return
	finishing = true
	add_score(100)
	GameState.call_deferred("next_level")

func _on_item_picked_up(points = 10):
	add_score(points)
	GameState.sound("pickup2")

func add_score(points):
	score += points
	GameState.score = score
	score_changed.emit(score)
	hud.update_score(score)

func _on_player_died():
	if finishing:
		return
	finishing = true
	GameState.call_deferred("show_menu", "lose")

