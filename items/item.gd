extends Area2D
signal picked_up(points)
var collected = false
var points = 10

func init(kind, spawn_position):
	points = 25 if kind == "gem" else 10
	$Sprite2D.texture = load("res://assets/sprites/%s.png" % kind)
	position = spawn_position
	$AnimationPlayer.get_animation("idle").loop_mode = Animation.LOOP_LINEAR

func _on_body_entered(body):
	if collected or not body.is_in_group("player"):
		return
	collected = true
	picked_up.emit(points)
	queue_free()

