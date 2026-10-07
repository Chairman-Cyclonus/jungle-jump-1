extends CharacterBody2D
signal life_changed(value)
signal died
@export var gravity = 900.0
@export var run_speed = 160.0
@export var jump_speed = -330.0
@export var max_fall_speed = 600.0
@export var climb_speed = 95.0
enum {IDLE, RUN, JUMP, HURT, DEAD, CLIMB}
var state = IDLE
var life = 3: set = set_life
var jump_count = 0
var is_on_ladder = false
var invulnerability = 0.0
var hurt_time = 0.0
var coyote_time = 0.0
var jump_buffer = 0.0
var dust: CPUParticles2D

func _ready():
	add_to_group("player")
	collision_mask = 1
	floor_snap_length = 4.0
	dust = CPUParticles2D.new()
	dust.amount = 12
	dust.lifetime = 0.3
	dust.one_shot = true
	dust.explosiveness = 1.0
	dust.direction = Vector2.UP
	dust.spread = 70.0
	dust.initial_velocity_min = 12
	dust.initial_velocity_max = 35
	dust.gravity = Vector2(0, 60)
	dust.scale_amount_min = 1.0
	dust.scale_amount_max = 2.0
	var gradient = Gradient.new()
	gradient.colors = PackedColorArray([Color("d8bc91"), Color(0.85, 0.74, 0.57, 0)])
	dust.color_ramp = gradient
	dust.emitting = false
	add_child(dust)
	change_state(IDLE)

func change_state(next_state):
	state = next_state
	match state:
		IDLE: $AnimationPlayer.play("idle")
		RUN: $AnimationPlayer.play("run")
		JUMP: $AnimationPlayer.play("jump_up" if velocity.y < 0 else "jump_down")
		HURT: $AnimationPlayer.play("hurt")
		CLIMB: $AnimationPlayer.stop()
		DEAD:
			velocity = Vector2.ZERO
			hide()
			died.emit()

func _physics_process(delta):
	if state == DEAD:
		return
	invulnerability = maxf(0.0, invulnerability - delta)
	hurt_time = maxf(0.0, hurt_time - delta)
	$Sprite2D.modulate.a = 0.4 if invulnerability > 0 and int(invulnerability * 14) % 2 == 0 else 1.0
	var grounded = is_on_floor()
	coyote_time = 0.10 if grounded else maxf(0.0, coyote_time - delta)
	jump_buffer = 0.12 if Input.is_action_just_pressed("jump") else maxf(0.0, jump_buffer - delta)
	if grounded:
		jump_count = 0
	var horizontal = Input.get_axis("left", "right")
	var vertical = Input.get_axis("up", "down")
	if hurt_time > 0:
		velocity.y = minf(velocity.y + gravity * delta, max_fall_speed)
		move_and_slide()
		return
	if state == CLIMB and not is_on_ladder:
		change_state(JUMP)
	if is_on_ladder and vertical != 0:
		change_state(CLIMB)
	velocity.x = horizontal * run_speed
	if horizontal != 0:
		$Sprite2D.flip_h = horizontal < 0
	if state == CLIMB:
		velocity.y = vertical * climb_speed
		$Sprite2D.frame = 1 + int(Time.get_ticks_msec() / 140) % 2 if vertical != 0 else 0
	else:
		velocity.y = minf(velocity.y + gravity * delta, max_fall_speed)
	if jump_buffer > 0 and (coyote_time > 0 or jump_count < 2 or state == CLIMB):
		var first_jump = coyote_time > 0 or state == CLIMB or jump_count == 0
		velocity.y = jump_speed if first_jump else jump_speed * 0.72
		jump_count = 1 if first_jump else 2
		jump_buffer = 0
		coyote_time = 0
		change_state(JUMP)
		GameState.sound("jump4")
	if Input.is_action_just_released("jump") and velocity.y < -150:
		velocity.y = -150
	move_and_slide()
	if is_on_floor() and not grounded:
		dust.restart()
		dust.emitting = true
	if state != CLIMB:
		change_state((RUN if horizontal != 0 else IDLE) if is_on_floor() else JUMP)

func reset(spawn_position):
	position = spawn_position
	velocity = Vector2.ZERO
	jump_count = 0
	jump_buffer = 0
	coyote_time = 0
	is_on_ladder = false
	invulnerability = 0
	hurt_time = 0
	show()
	change_state(IDLE)
	life = 3

func set_life(value):
	life = clampi(value, 0, 3)
	life_changed.emit(life)
	if life == 0 and state != DEAD:
		change_state(DEAD)

func hurt(direction = -1.0):
	if invulnerability > 0 or state == DEAD:
		return
	invulnerability = 1.3
	hurt_time = 0.22
	velocity = Vector2(130 * direction, -180)
	change_state(HURT)
	life -= 1
	GameState.sound("hurt1")

func bounce():
	velocity.y = -260
	jump_count = 1
	change_state(JUMP)

