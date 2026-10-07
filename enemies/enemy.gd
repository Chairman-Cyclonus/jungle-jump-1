extends CharacterBody2D
signal defeated
@export var patrol_distance = 64.0
@export var speed = 38.0
var origin_x = 0.0
var facing = 1.0
var dead = false
var animation_time = 0.0
var player: CharacterBody2D
@onready var sprite = $Sprite2D

func _ready():
	origin_x = position.x
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta):
	if dead:
		return
	animation_time += delta
	sprite.frame = int(animation_time * 10) % 6
	if (position.x > origin_x + patrol_distance and facing > 0) or (position.x < origin_x - patrol_distance and facing < 0):
		facing *= -1
	velocity = Vector2(facing * speed, minf(velocity.y + 900 * delta, 600))
	sprite.flip_h = facing > 0
	move_and_slide()
	if is_on_wall():
		facing *= -1
	if not is_instance_valid(player) or player.state == player.DEAD:
		return
	var difference = player.global_position - global_position
	if absf(difference.x) < 23 and difference.y > -28 and difference.y < 18:
		if player.velocity.y > 20 and difference.y < -9:
			take_damage()
			player.bounce()
		else:
			player.hurt(-1.0 if difference.x < 0 else 1.0)

func take_damage():
	if dead:
		return
	dead = true
	defeated.emit()
	GameState.sound("enemy_hit")
	sprite.texture = preload("res://assets/sprites/enemy-death.png")
	sprite.frame = 0
	var tween = create_tween()
	tween.tween_method(func(frame): sprite.frame = frame, 0, 5, 0.30)
	tween.tween_callback(queue_free)

