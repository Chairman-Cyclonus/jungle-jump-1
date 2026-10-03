extends CharacterBody2D
@export var gravity = 750
@export var run_speed = 150
@export var jump_speed = -100
signal life_changed
signal died

var life = 3: set = set_life
func set_life(value):
	life = value
	life_changed.emit(life)
	if life <= 0:
		change_state(DEAD)

enum {IDLE, RUN, JUMP, HURT, DEAD}

var state = IDLE

func _ready():
	change_state(IDLE)
	

func change_state(new_state):
	state = new_state
	match state:
		IDLE:
			$AnimationPlayer.play("idle")
		RUN:
			$AnimationPlayer.play("run")
		HURT:
			$AnimationPlayer.play("hurt")
			velocity.y = -200
			velocity.x = -100 * sign(velocity.x)
			life -= 1
			await get_tree().create_timer(0.5).timeout
			change_state(IDLE)
		JUMP:
			$AnimationPlayer.play("jump_up")
		DEAD:
			died.emit()
			hide()
			
func get_input():
	if state == HURT:
		return
	var right = Input.is_action_pressed("right")
	var left = Input.is_action_pressed("left")
	var jump = Input.is_action_just_pressed("jump")
	
	velocity.x = 0
	
	if right:
		velocity.x += run_speed
		$Sprite2D.flip_h = false
		
	if left:
		velocity.x -= run_speed
		$Sprite2D.flip_h = true
		
	#allow us to jump if jump is pressed AND if we are on the floor
	if jump and is_on_floor():
		change_state(JUMP)
		velocity.y = jump_speed
		
	#if we are currently in idle and then our velocity changes to were it is no longer 0
	if state == IDLE and velocity.x != 0:
		change_state(RUN)
	
	#transition from running to idle
	if state == RUN and velocity.x == 0:
		change_state(IDLE)
		
	#jump transition
	if state in [IDLE,RUN] and !is_on_floor():
		change_state(JUMP)
			
func _physics_process(delta):
	velocity.y += gravity * delta
	get_input()
	move_and_slide()
	
	if state == JUMP and is_on_floor():
		change_state(IDLE)
	
	if state == JUMP and velocity.y > 0:
		$AnimationPlayer.play("jump_down")

func reset(_position):
	position = _position
	show()
	change_state(IDLE)
	
	
func hurt():
	if state != HURT:
		change_state(HURT)
