extends Node
func _ready():
	var path = "res://Levels/level%02d.tscn" % clampi(GameState.current_level, 1, 2)
	add_child(load(path).instantiate())

