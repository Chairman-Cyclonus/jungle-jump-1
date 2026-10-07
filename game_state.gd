extends Node
const LEVEL_COUNT = 2
var current_level = 1
var score = 0
var level_start_score = 0
var menu_mode = "title"
var muted = false
var music: AudioStreamPlayer
var music_track = ""

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	music = AudioStreamPlayer.new()
	music.volume_db = -20
	add_child(music)
	music.finished.connect(func(): music.play())

func start_game():
	score = 0
	level_start_score = 0
	current_level = 1
	load_level()

func load_level():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://main.tscn")

func retry_level():
	score = level_start_score
	load_level()

func next_level():
	current_level += 1
	level_start_score = score
	if current_level > LEVEL_COUNT:
		show_menu("win")
	else:
		load_level()

func show_menu(mode = "title"):
	menu_mode = mode
	get_tree().paused = false
	get_tree().change_scene_to_file("res://ui/title.tscn")

func play_music(track):
	if DisplayServer.get_name() == "headless":
		return
	if music_track == track and music.playing:
		return
	music_track = track
	music.stream = load("res://assets/audio/%s.ogg" % track)
	music.play()

func sound(effect):
	if DisplayServer.get_name() == "headless":
		return
	var player = AudioStreamPlayer.new()
	player.stream = load("res://assets/audio/%s.ogg" % effect)
	player.volume_db = -13
	add_child(player)
	player.finished.connect(player.queue_free)
	player.play()

func toggle_mute():
	muted = not muted
	AudioServer.set_bus_mute(0, muted)

func _unhandled_key_input(event):
	if event.pressed and not event.echo and event.keycode == KEY_M:
		toggle_mute()


func _exit_tree():
	for child in get_children():
		if child is AudioStreamPlayer:
			child.stop()
			child.stream = null

