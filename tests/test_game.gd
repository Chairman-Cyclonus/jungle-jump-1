extends SceneTree
var gs
var checks = 0
func _initialize():
	call_deferred("run_tests")
func check(condition, description):
	if not condition:
		push_error("FAIL: " + description)
		quit(1)
		assert(condition, description)
	checks += 1
	print("PASS: " + description)
func frames(count):
	for i in range(count):
		await physics_frame
		await process_frame
func run_tests():
	gs = root.get_node("GameState")
	gs.start_game()
	await frames(40)
	var level = current_scene.get_child(0)
	var p = level.get_node("Player")
	check(p.is_on_floor(), "spawn on solid ground")
	var base_y = p.position.y
	Input.action_press("jump")
	var peak = base_y
	for i in range(27):
		await frames(1)
		peak = minf(peak, p.position.y)
	check(base_y - peak > 52, "full jump clears 48-pixel steps")
	Input.action_release("jump")
	await frames(2)
	Input.action_press("jump")
	await frames(2)
	check(p.jump_count == 2 and p.velocity.y < 0, "double jump")
	Input.action_release("jump")
	await frames(60)
	check(p.is_on_floor(), "landing after double jump")
	p.position = Vector2(1128, 195)
	p.velocity = Vector2.ZERO
	await frames(3)
	Input.action_press("up")
	await frames(25)
	check(p.position.y < 175 and p.state == p.CLIMB, "ladder climbing")
	Input.action_release("up")
	var score_before = gs.score
	var item = get_nodes_in_group("collectibles")[0]
	item._on_body_entered(p)
	await frames(2)
	check(gs.score > score_before, "collecting adds score")
	var enemy = get_nodes_in_group("enemies")[0]
	p.position = enemy.position + Vector2(0, -23)
	p.velocity = Vector2(0, 100)
	p.change_state(p.JUMP)
	await frames(2)
	check(enemy.dead and p.velocity.y < 0, "stomping enemy bounces player")
	check(gs.score >= score_before + 60, "enemy awards points")
	p.position = Vector2(64, 200)
	p.invulnerability = 0
	p.hurt(1)
	var health = p.life
	p.hurt(1)
	check(health == 2 and p.life == 2, "damage and invulnerability")
	p.hurt_time = 0
	p.velocity = Vector2.ZERO
	await frames(5)
	p.position = Vector2(1216, 200)
	await frames(3)
	check(level.checkpoint_active, "checkpoint activation")
	p.position = Vector2(1300, 450)
	await frames(3)
	check(p.position.distance_to(level.checkpoint) < 20 and p.life == 1, "fall returns to checkpoint and costs heart")
	for child in level.scenery.get_children():
		check(not child is CollisionObject2D and child.get_child_count() == 0, "scenery is collision-free: " + str(child.name))
	var platform = get_nodes_in_group("platforms")[0]
	var before = platform.position
	await frames(20)
	check(platform.position.distance_to(before) > 1, "moving platform travels")
	level.hud.toggle_pause()
	check(paused, "pause")
	level.hud.toggle_pause()
	check(not paused, "resume")
	level.complete_level()
	await frames(10)
	check(gs.current_level == 2 and current_scene.get_child(0).level_number == 2, "level 1 exit loads level 2")
	level = current_scene.get_child(0)
	level.complete_level()
	await frames(10)
	check(gs.menu_mode == "win" and current_scene.name == "Title", "level 2 exit loads win screen")
	gs.start_game()
	await frames(10)
	level = current_scene.get_child(0)
	level.get_node("Player").life = 0
	await frames(10)
	check(gs.menu_mode == "lose" and current_scene.name == "Title", "death loads retry menu")
	gs.retry_level()
	await frames(10)
	check(current_scene.get_child(0).get_node("Player").life == 3, "retry restores health")
	print("ALL CHECKS PASSED: ", checks)
	quit()

