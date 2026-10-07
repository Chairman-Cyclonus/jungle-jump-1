extends SceneTree
func _initialize():
	call_deferred("test_routes")
func step():
	await physics_frame
	await process_frame
func test_routes():
	var gs = root.get_node("GameState")
	for level_number in [1, 2]:
		gs.current_level = level_number
		gs.score = 0
		gs.load_level()
		for i in range(30):
			await step()
		var level = current_scene.get_child(0)
		var p = level.get_node("Player")
		# Isolate route geometry; combat and damage are covered by test_game.gd.
		for enemy in get_nodes_in_group("enemies"):
			enemy.set_physics_process(false)
		Input.action_press("right")
		var farthest = 0.0
		var reached = false
		for frame in range(1600):
			if not is_instance_valid(level) or level.finishing:
				reached = gs.current_level > level_number or (is_instance_valid(p) and p.life > 0)
				break
			farthest = maxf(farthest, p.position.x)
			if p.is_on_floor():
				if Input.is_action_pressed("jump"):
					Input.action_release("jump")
				else:
					Input.action_press("jump")
			elif p.jump_count == 1 and p.velocity.y > -25:
				if Input.is_action_pressed("jump"):
					Input.action_release("jump")
				else:
					Input.action_press("jump")
			elif p.jump_count == 2 and p.velocity.y > 0:
				Input.action_release("jump")
			await step()
		Input.action_release("right")
		Input.action_release("jump")
		if not reached:
			push_error("Route blocked, level %d at x=%.1f" % [level_number, farthest])
			quit(1)
			return
		print("PASS: traversed complete level ", level_number, " using movement and jumps")
		for i in range(10):
			await step()
	quit()

