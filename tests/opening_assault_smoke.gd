extends SceneTree

var failures = 0

func _initialize():
	run_smoke_test.call_deferred()

func expect_true(condition, message):
	if condition:
		return
	failures += 1
	push_error("OPENING ASSAULT: " + message)

func run_smoke_test():
	var packed_scene = load("res://Main.tscn")
	var game = packed_scene.instantiate()
	root.add_child(game)
	await process_frame

	game.start_game()
	game.intro_timer = 0.0
	game.mission_text_timer = 0.0
	game.player_x = 1900.0
	game.camera_x = 1580.0

	game.break_prop(0, 1.0)
	game.spawn_enemy_death(2150.0, 0, 1.0)
	game.boss_started = true
	game.boss_hp = 8
	game.boss_x = 2420.0
	game.boss_attack_timer = 0.0

	for frame in range(90):
		await process_frame

	expect_true(not game.prop_alive[0], "breakable prop did not enter its destroyed state")
	expect_true(game.debris_pos.size() >= 20, "physical debris pool was not populated")
	expect_true(game.drop_pos.size() >= 2, "enemy and prop drops were not spawned")
	expect_true(game.hostile_shot_pos.size() >= 2, "Executioner did not fire its projectile pattern")
	expect_true(game.enemy_last_smashed.size() == game.enemy_x.size(), "spawn-safe enemy state arrays lost alignment")

	game.music_player.stop()
	game.queue_free()
	await process_frame
	if failures == 0:
		print("OPENING ASSAULT SMOKE TEST: PASS")
	quit(failures)
