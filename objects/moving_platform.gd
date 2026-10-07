extends AnimatableBody2D
@export var offset = Vector2(80, 0)
@export var duration = 4.0
func _ready():
	var start = position
	var tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.set_loops().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "position", start + offset, duration / 2)
	tween.tween_property(self, "position", start, duration / 2)

