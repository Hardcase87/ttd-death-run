extends Node2D

const WORLD_W = 32000.0
const FLOOR_Y = 600.0
const CONTROL_TOP = 625.0
const MAX_AMMO = 120

var hc_idle = preload("res://assets/sprites/hardcase/hardcase_01.png")
var hc_run1 = preload("res://assets/sprites/hardcase/hardcase_02.png")
var hc_run2 = preload("res://assets/sprites/hardcase/hardcase_03.png")
var hc_run3 = preload("res://assets/sprites/hardcase/hardcase_04.png")
var hc_jump = preload("res://assets/sprites/hardcase/hardcase_05.png")
var hc_shoot = preload("res://assets/sprites/hardcase/hardcase_07.png")
var hc_smash = preload("res://assets/sprites/hardcase/hardcase_08.png")
var hc_hurt = preload("res://assets/sprites/hardcase/hardcase_09.png")
var hc_win = preload("res://assets/sprites/hardcase/hardcase_10.png")

var level_bg = preload("res://assets/backgrounds/vhs_quarter_neon_background.png")
var environment_sheet = preload("res://assets/environment/neon_vhs_palace_asset_sheet.png")
var enemy_sheet = preload("res://assets/enemies/neon_cyberpunk_enemy_sprite_sheet.png")
var hud_sheet = preload("res://assets/hud/neon_vhs_cyberpunk_hud_asset_sheet.png")

var music_stream = preload("res://audio/ttd_vhs_assault.wav")
var sfx_shoot = preload("res://audio/drrrt.wav")
var sfx_hit = preload("res://audio/hit.wav")
var sfx_smash = preload("res://audio/smash.wav")
var sfx_pickup = preload("res://audio/pickup.wav")
var sfx_death = preload("res://audio/death.wav")
var sfx_relay = preload("res://audio/relay.wav")
var sfx_boss = preload("res://audio/boss.wav")

var music_player
var sfx_a
var sfx_b
var sfx_c
var sfx_slot = 0

var punk_idle_region = Rect2(0, 0, 482, 271)
var punk_run_region = Rect2(483, 0, 482, 271)
var punk_attack_region = Rect2(966, 0, 482, 271)
var tdi_idle_region = Rect2(0, 272, 482, 271)
var tdi_run_region = Rect2(483, 272, 482, 271)
var tdi_attack_region = Rect2(966, 272, 482, 271)
var toxic_idle_region = Rect2(0, 543, 482, 271)
var toxic_run_region = Rect2(483, 543, 482, 271)
var toxic_attack_region = Rect2(966, 543, 482, 271)

var env_store = Rect2(10, 8, 505, 670)
var env_skull_billboard = Rect2(520, 8, 500, 355)
var env_rewind_billboard = Rect2(1035, 8, 355, 370)
var env_tape_boost = Rect2(520, 360, 280, 310)
var env_toxic_barrels = Rect2(790, 370, 280, 300)
var env_dumpster = Rect2(1070, 380, 365, 295)
var env_vhs_crates = Rect2(20, 690, 285, 220)
var env_crt_stack = Rect2(305, 675, 225, 235)
var env_arcade = Rect2(525, 675, 275, 240)
var env_barricade = Rect2(800, 690, 310, 235)
var env_streetlamp = Rect2(1110, 600, 300, 325)
var env_tape = Rect2(610, 915, 220, 165)

var hud_stage = Rect2(35, 320, 300, 125)
var hud_score = Rect2(350, 320, 300, 125)
var hud_health = Rect2(665, 320, 320, 125)
var hud_lives = Rect2(995, 320, 190, 125)
var hud_tbn = Rect2(1190, 320, 230, 125)
var hud_ticker = Rect2(35, 615, 1035, 110)
var hud_left = Rect2(35, 735, 315, 155)
var hud_right = Rect2(355, 735, 330, 155)
var hud_jump = Rect2(680, 735, 315, 155)
var hud_smash = Rect2(1000, 735, 390, 155)

var player_x = 220.0
var player_y = FLOOR_Y - 126.0
var player_vx = 0.0
var player_vy = 0.0
var player_grounded = true
var player_facing = 1.0
var player_health = 100
var player_lives = 3
var ammo = 90
var smash_timer = 0.0
var hurt_timer = 0.0
var shoot_timer = 0.0
var shoot_anim_timer = 0.0
var stage_finished = false

var camera_x = 0.0
var shake_time = 0.0
var shake_power = 0.0
var flash_time = 0.0
var score = 0
var checkpoint = 220.0
var checkpoint_index = 0
var game_time = 0.0
var run_anim_time = 0.0

var game_started = false
var title_pulse = 0.0
var intro_timer = 3.6
var mission_text_timer = 6.0
var jump_burst_time = 0.0
var landing_burst_time = 0.0
var boss_started = false
var boss_hp = 18
var boss_x = 30950.0
var boss_attack_timer = 0.0

# COMBAT FEEL / SCORE
var shots_fired = 0
var shots_hit = 0
var kills = 0
var combo = 0
var best_combo = 0
var combo_timer = 0.0
var muzzle_flash_timer = 0.0
var hitstop_timer = 0.0
var encounter_text = ""
var encounter_text_timer = 0.0
var results_timer = 0.0

# Ambushes + relay lockdown waves.
var ambush_x = [4600.0, 15100.0, 26300.0]
var ambush_done = [false, false, false]
var relay_wave_done = [false, false]

# Lightweight screen-space combat FX.
var spark_x = []
var spark_y = []
var spark_t = []
var burst_x = []
var burst_y = []
var burst_t = []

var touch_left = false
var touch_right = false
var touch_jump = false
var touch_smash = false
var touch_shoot = false
var active_touch_left = -1
var active_touch_right = -1
var active_touch_jump = -1
var active_touch_smash = -1
var active_touch_shoot = -1

var bullet_x = []
var bullet_y = []
var bullet_dir = []
var bullet_alive = []

var enemy_home = [
	900.0, 1250.0, 1800.0, 3200.0, 3500.0, 3900.0,
	5400.0, 5900.0, 6300.0, 7900.0, 8300.0, 8700.0,
	9900.0, 10300.0, 10700.0, 12100.0, 12500.0, 14000.0,
	14400.0, 14900.0, 16300.0, 16700.0, 17100.0, 19100.0,
	19500.0, 19900.0, 21300.0, 21700.0, 22100.0, 24000.0,
	24400.0, 25800.0, 27300.0, 28900.0
]
var enemy_x = [
	900.0, 1250.0, 1800.0, 3200.0, 3500.0, 3900.0,
	5400.0, 5900.0, 6300.0, 7900.0, 8300.0, 8700.0,
	9900.0, 10300.0, 10700.0, 12100.0, 12500.0, 14000.0,
	14400.0, 14900.0, 16300.0, 16700.0, 17100.0, 19100.0,
	19500.0, 19900.0, 21300.0, 21700.0, 22100.0, 24000.0,
	24400.0, 25800.0, 27300.0, 28900.0
]
var enemy_type = [
	0,0,2, 1,0,2, 0,1,2, 0,0,1, 2,1,0, 0,2,1,
	0,2, 1,0,2, 0,1,2, 1,2,0, 0,1,2,1,2
]
var enemy_hp = [
	3,3,4, 5,3,4, 3,5,4, 4,4,5, 5,6,4, 4,5,6,
	4,5, 6,4,5, 5,6,5, 7,6,5, 5,7,6,7,8
]
var enemy_alive = [
	true,true,true,true,true,true,true,true,true,true,true,true,
	true,true,true,true,true,true,true,true,true,true,true,true,
	true,true,true,true,true,true,true,true,true,true
]
var enemy_attack_timer = [
	0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,
	0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,
	0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0
]

var relay_x = [10500.0, 21800.0]
var relay_hp = [8, 10]
var relay_alive = [true, true]

var pickup_x = [2750.0, 7050.0, 11350.0, 15600.0, 22550.0, 26800.0, 29600.0]
var pickup_type = [0, 1, 0, 1, 0, 1, 0]
var pickup_alive = [true,true,true,true,true,true,true]

func _ready():
	music_player = AudioStreamPlayer.new()
	sfx_a = AudioStreamPlayer.new()
	sfx_b = AudioStreamPlayer.new()
	sfx_c = AudioStreamPlayer.new()
	add_child(music_player)
	add_child(sfx_a)
	add_child(sfx_b)
	add_child(sfx_c)
	music_player.stream = music_stream
	music_player.volume_db = -10.0
	queue_redraw()

func play_sfx(stream, volume_db):
	var p = sfx_a
	if sfx_slot == 1:
		p = sfx_b
	elif sfx_slot == 2:
		p = sfx_c
	sfx_slot += 1
	if sfx_slot > 2:
		sfx_slot = 0
	p.stream = stream
	p.volume_db = volume_db
	p.play()

func start_game():
	if game_started:
		return
	game_started = true
	intro_timer = 3.6
	mission_text_timer = 6.0
	music_player.play()
	play_sfx(sfx_relay, -8.0)
	kick_camera(0.18, 5.0)
	queue_redraw()

func _input(event):
	if event is InputEventScreenTouch:
		var pos = event.position
		if event.pressed and not game_started:
			start_game()
			return
		if event.pressed:
			if Rect2(18, 637, 155, 72).has_point(pos):
				touch_left = true
				active_touch_left = event.index
			elif Rect2(185, 637, 155, 72).has_point(pos):
				touch_right = true
				active_touch_right = event.index
			elif Rect2(780, 637, 145, 72).has_point(pos):
				touch_jump = true
				active_touch_jump = event.index
			elif Rect2(935, 637, 145, 72).has_point(pos):
				touch_smash = true
				active_touch_smash = event.index
			elif Rect2(1090, 637, 175, 72).has_point(pos):
				touch_shoot = true
				active_touch_shoot = event.index
		else:
			if event.index == active_touch_left:
				touch_left = false
				active_touch_left = -1
			if event.index == active_touch_right:
				touch_right = false
				active_touch_right = -1
			if event.index == active_touch_jump:
				active_touch_jump = -1
			if event.index == active_touch_smash:
				active_touch_smash = -1
			if event.index == active_touch_shoot:
				touch_shoot = false
				active_touch_shoot = -1

func _process(delta):
	game_time += delta
	run_anim_time += delta
	title_pulse += delta
	jump_burst_time = max(0.0, jump_burst_time - delta)
	landing_burst_time = max(0.0, landing_burst_time - delta)

	if not game_started:
		if Input.is_key_pressed(KEY_ENTER) or Input.is_key_pressed(KEY_SPACE):
			start_game()
		queue_redraw()
		return

	intro_timer = max(0.0, intro_timer - delta)
	mission_text_timer = max(0.0, mission_text_timer - delta)
	shake_time = max(0.0, shake_time - delta)
	flash_time = max(0.0, flash_time - delta)
	shoot_timer = max(0.0, shoot_timer - delta)
	shoot_anim_timer = max(0.0, shoot_anim_timer - delta)
	muzzle_flash_timer = max(0.0, muzzle_flash_timer - delta)
	combo_timer = max(0.0, combo_timer - delta)
	encounter_text_timer = max(0.0, encounter_text_timer - delta)
	boss_attack_timer = max(0.0, boss_attack_timer - delta)
	if combo_timer <= 0.0:
		combo = 0
	update_fx(delta)

	if hitstop_timer > 0.0:
		hitstop_timer = max(0.0, hitstop_timer - delta)
		queue_redraw()
		return

	if not music_player.playing:
		music_player.play()

	for i in range(enemy_attack_timer.size()):
		enemy_attack_timer[i] = max(0.0, enemy_attack_timer[i] - delta)

	handle_input(delta)
	update_player(delta)
	update_bullets(delta)
	update_enemies(delta)
	update_relays()
	update_pickups()
	update_checkpoints()
	update_encounters()
	update_boss()

	var target_camera = clamp(player_x - 360.0, 0.0, WORLD_W - 1280.0)
	camera_x = lerp(camera_x, target_camera, min(1.0, delta * 6.5))
	queue_redraw()

func handle_input(delta):
	if stage_finished or intro_timer > 0.0:
		player_vx = move_toward(player_vx, 0.0, 2100.0 * delta)
		return

	var direction = 0.0
	if Input.is_action_pressed("move_left") or touch_left:
		direction -= 1.0
	if Input.is_action_pressed("move_right") or touch_right:
		direction += 1.0

	if direction != 0.0:
		player_facing = direction

	player_vx = move_toward(player_vx, direction * 430.0, 1850.0 * delta)

	var jump_pressed = Input.is_action_just_pressed("jump")
	if touch_jump:
		jump_pressed = true
		touch_jump = false

	if jump_pressed and player_grounded:
		player_vy = -1080.0
		player_grounded = false
		jump_burst_time = 0.18
		kick_camera(0.07, 4.0)

	var smash_pressed = Input.is_action_just_pressed("smash")
	if touch_smash:
		smash_pressed = true
		touch_smash = false

	if smash_pressed and smash_timer <= 0.0:
		smash_timer = 0.30
		play_sfx(sfx_smash, -5.0)

	var fire_pressed = Input.is_key_pressed(KEY_K) or touch_shoot
	if fire_pressed and shoot_timer <= 0.0 and ammo > 0:
		fire_bullet()

func fire_bullet():
	shoot_timer = 0.105
	shoot_anim_timer = 0.15
	muzzle_flash_timer = 0.055
	shots_fired += 1
	ammo -= 1
	var bx = player_x + 118.0
	if player_facing < 0.0:
		bx = player_x - 54.0
	bullet_x.append(bx)
	bullet_y.append(player_y + 24.0)
	bullet_dir.append(player_facing)
	bullet_alive.append(true)
	play_sfx(sfx_shoot, -8.0)
	kick_camera(0.035, 2.0)

func update_player(delta):
	smash_timer = max(0.0, smash_timer - delta)
	hurt_timer = max(0.0, hurt_timer - delta)

	var was_grounded = player_grounded
	player_vy += 2450.0 * delta
	player_x += player_vx * delta
	player_y += player_vy * delta
	player_x = clamp(player_x, 60.0, WORLD_W - 80.0)

	if player_y >= FLOOR_Y - 126.0:
		player_y = FLOOR_Y - 126.0
		if not was_grounded and player_vy > 360.0:
			landing_burst_time = 0.20
			kick_camera(0.11, 7.0)
		player_vy = 0.0
		player_grounded = true

	if player_x >= WORLD_W - 300.0 and boss_hp <= 0 and not stage_finished:
		stage_finished = true
		results_timer = 99.0
		score += 10000
		encounter_text = "VHS QUARTER // CLEARED"
		encounter_text_timer = 3.0
		play_sfx(sfx_relay, -2.0)
		kick_camera(0.45, 18.0)

func update_bullets(delta):
	for b in range(bullet_x.size()):
		if not bullet_alive[b]:
			continue
		bullet_x[b] += bullet_dir[b] * 920.0 * delta
		if bullet_x[b] < camera_x - 100.0 or bullet_x[b] > camera_x + 1400.0:
			bullet_alive[b] = false
			continue

		for i in range(enemy_x.size()):
			if not enemy_alive[i] or not bullet_alive[b]:
				continue
			if abs(bullet_x[b] - enemy_x[i]) < 96.0 and abs(bullet_y[b] - (FLOOR_Y - 70.0)) < 85.0:
				enemy_hp[i] -= 1
				bullet_alive[b] = false
				shots_hit += 1
				score += 50
				add_spark(enemy_x[i], FLOOR_Y - 90.0)
				play_sfx(sfx_hit, -9.0)
				flash_time = 0.025
				hitstop_timer = 0.018
				if enemy_hp[i] <= 0:
					enemy_alive[i] = false
					register_kill(enemy_x[i])
					play_sfx(sfx_death, -6.0)
					kick_camera(0.14, 9.0)

		for r in range(relay_x.size()):
			if relay_alive[r] and bullet_alive[b] and abs(bullet_x[b] - relay_x[r]) < 75.0:
				relay_hp[r] -= 1
				bullet_alive[b] = false
				shots_hit += 1
				score += 75
				add_spark(relay_x[r], FLOOR_Y - 120.0)
				if relay_hp[r] <= 0:
					relay_alive[r] = false
					score += 1500
					encounter_text = "TDI SIGNAL NODE DESTROYED"
					encounter_text_timer = 2.2
					play_sfx(sfx_relay, -3.0)
					kick_camera(0.42, 18.0)

		if boss_started and boss_hp > 0 and bullet_alive[b] and abs(bullet_x[b] - boss_x) < 145.0:
			boss_hp -= 1
			bullet_alive[b] = false
			shots_hit += 1
			score += 100
			add_spark(boss_x, FLOOR_Y - 130.0)
			play_sfx(sfx_hit, -7.0)
			hitstop_timer = 0.022
			if boss_hp <= 0:
				score += 5000
				kills += 1
				add_burst(boss_x, FLOOR_Y - 120.0)
				encounter_text = "EXECUTIONER TERMINATED"
				encounter_text_timer = 2.8
				play_sfx(sfx_death, -1.0)
				kick_camera(0.72, 25.0)

func update_enemies(delta):
	for i in range(enemy_x.size()):
		if not enemy_alive[i]:
			continue

		var dx = player_x - enemy_x[i]
		var chase_range = 430.0
		if enemy_type[i] == 1:
			chase_range = 520.0
		elif enemy_type[i] == 2:
			chase_range = 380.0

		if abs(dx) < chase_range:
			var enemy_dir = 1.0
			if dx < 0.0:
				enemy_dir = -1.0
			var spd = 92.0
			if enemy_type[i] == 0:
				spd = 112.0
			elif enemy_type[i] == 1:
				spd = 72.0
			enemy_x[i] += enemy_dir * spd * delta
		else:
			enemy_x[i] = move_toward(enemy_x[i], enemy_home[i], 55.0 * delta)

		enemy_x[i] = clamp(enemy_x[i], enemy_home[i] - 210.0, enemy_home[i] + 210.0)
		var touching = abs(player_x - enemy_x[i]) < 104.0 and abs((player_y + 60.0) - (FLOOR_Y - 62.0)) < 72.0

		if touching:
			enemy_attack_timer[i] = 0.25
			if smash_timer > 0.0:
				enemy_hp[i] -= 2
				enemy_x[i] += player_facing * 105.0
				kick_camera(0.14, 9.0)
				flash_time = 0.06
				if enemy_hp[i] <= 0:
					enemy_alive[i] = false
					register_kill(enemy_x[i])
					play_sfx(sfx_death, -6.0)
			elif hurt_timer <= 0.0:
				var damage = 10
				if enemy_type[i] == 1:
					damage = 14
				elif enemy_type[i] == 2:
					damage = 12
				player_health -= damage
				hurt_timer = 0.8
				player_vx = -player_facing * 250.0
				kick_camera(0.12, 7.0)
				if player_health <= 0:
					lose_life()

func update_relays():
	pass

func update_pickups():
	for i in range(pickup_x.size()):
		if not pickup_alive[i]:
			continue
		if abs(player_x - pickup_x[i]) < 72.0:
			pickup_alive[i] = false
			if pickup_type[i] == 0:
				ammo = min(MAX_AMMO, ammo + 40)
			else:
				player_health = min(100, player_health + 35)
			score += 250
			play_sfx(sfx_pickup, -5.0)

func update_checkpoints():
	if player_x > 7800.0 and checkpoint_index < 1:
		checkpoint_index = 1
		checkpoint = 7800.0
		mission_text_timer = 2.5
	if player_x > 16000.0 and checkpoint_index < 2:
		checkpoint_index = 2
		checkpoint = 16000.0
		mission_text_timer = 2.5
	if player_x > 24500.0 and checkpoint_index < 3:
		checkpoint_index = 3
		checkpoint = 24500.0
		mission_text_timer = 2.5

func update_boss():
	if player_x > 30100.0 and not boss_started:
		if not relay_alive[0] and not relay_alive[1]:
			boss_started = true
			mission_text_timer = 4.0
			play_sfx(sfx_boss, -2.0)
		else:
			player_x = min(player_x, 30070.0)

func spawn_enemy(world_x, kind, hp):
	enemy_home.append(world_x)
	enemy_x.append(world_x)
	enemy_type.append(kind)
	enemy_hp.append(hp)
	enemy_alive.append(true)
	enemy_attack_timer.append(0.0)

func update_encounters():
	for i in range(ambush_x.size()):
		if not ambush_done[i] and player_x > ambush_x[i]:
			ambush_done[i] = true
			encounter_text = "TBN AMBUSH // RATINGS SPIKE"
			encounter_text_timer = 2.4
			spawn_enemy(ambush_x[i] + 310.0, 0, 4 + i)
			spawn_enemy(ambush_x[i] + 520.0, 2, 5 + i)
			spawn_enemy(ambush_x[i] + 760.0, 1, 6 + i)
			play_sfx(sfx_boss, -9.0)
			kick_camera(0.16, 8.0)

	for r in range(relay_x.size()):
		if relay_alive[r] and not relay_wave_done[r] and abs(player_x - relay_x[r]) < 720.0:
			relay_wave_done[r] = true
			encounter_text = "TDI LOCKDOWN // DESTROY THE SIGNAL"
			encounter_text_timer = 2.8
			spawn_enemy(relay_x[r] - 430.0, 1, 6 + r)
			spawn_enemy(relay_x[r] + 390.0, 0, 5 + r)
			spawn_enemy(relay_x[r] + 650.0, 2, 6 + r)
			play_sfx(sfx_boss, -7.0)
			kick_camera(0.22, 11.0)

func register_kill(world_x):
	kills += 1
	combo += 1
	combo_timer = 2.2
	if combo > best_combo:
		best_combo = combo
	var bonus = 400 + combo * 125
	score += bonus
	add_burst(world_x, FLOOR_Y - 85.0)
	if combo == 3:
		encounter_text = "TRIPLE KILL // TBN CONCERNED"
		encounter_text_timer = 1.6
	elif combo == 5:
		encounter_text = "MUTANT RAMPAGE // x5"
		encounter_text_timer = 1.8
	elif combo == 8:
		encounter_text = "DEATH RUN // UNHINGED x8"
		encounter_text_timer = 2.0

func add_spark(world_x, world_y):
	spark_x.append(world_x)
	spark_y.append(world_y)
	spark_t.append(0.18)

func add_burst(world_x, world_y):
	burst_x.append(world_x)
	burst_y.append(world_y)
	burst_t.append(0.42)

func update_fx(delta):
	for i in range(spark_t.size()):
		spark_t[i] = max(0.0, spark_t[i] - delta)
	for i in range(burst_t.size()):
		burst_t[i] = max(0.0, burst_t[i] - delta)

func draw_combat_fx():
	for i in range(spark_t.size()):
		if spark_t[i] <= 0.0:
			continue
		var a = spark_t[i] / 0.18
		var sx = spark_x[i] - camera_x
		var sy = spark_y[i]
		draw_line(Vector2(sx - 18.0 * a, sy), Vector2(sx + 20.0 * a, sy - 13.0 * a), Color(1.0, 0.94, 0.2, a), 4.0)
		draw_line(Vector2(sx, sy - 19.0 * a), Vector2(sx + 9.0 * a, sy + 16.0 * a), Color(1.0, 0.18, 0.58, a), 3.0)
		draw_circle(Vector2(sx, sy), 8.0 * a, Color(1.0, 1.0, 0.82, a))

	for i in range(burst_t.size()):
		if burst_t[i] <= 0.0:
			continue
		var a = burst_t[i] / 0.42
		var bx = burst_x[i] - camera_x
		var by = burst_y[i]
		draw_circle(Vector2(bx, by), 52.0 * (1.0 - a), Color(1.0, 0.15, 0.50, 0.22 * a))
		draw_line(Vector2(bx - 48.0, by), Vector2(bx + 48.0, by), Color(0.54, 1.0, 0.17, a), 5.0)
		draw_line(Vector2(bx, by - 42.0), Vector2(bx, by + 42.0), Color(1.0, 0.90, 0.2, a), 4.0)

func lose_life():
	player_lives -= 1
	player_health = 100
	ammo = max(ammo, 45)
	player_x = checkpoint
	player_y = FLOOR_Y - 126.0
	kick_camera(0.30, 16.0)

	if player_lives < 0:
		player_lives = 3
		score = 0
		checkpoint = 220.0
		checkpoint_index = 0
		player_x = 220.0
		relay_hp = [8, 10]
		relay_alive = [true, true]
		ambush_done = [false, false, false]
		relay_wave_done = [false, false]
		combo = 0
		kills = 0
		shots_fired = 0
		shots_hit = 0

func kick_camera(duration, power):
	shake_time = duration
	shake_power = power

func get_shake_x():
	if shake_time <= 0.0:
		return 0.0
	return sin(game_time * 87.0) * shake_power

func get_shake_y():
	if shake_time <= 0.0:
		return 0.0
	return cos(game_time * 113.0) * shake_power * 0.55

func _draw():
	if not game_started:
		draw_title_screen()
		return

	draw_level_background()
	draw_level_environment()
	draw_relays()
	draw_pickups()
	draw_enemies()
	draw_bullets()
	draw_boss()
	draw_combat_fx()
	draw_player()
	draw_foreground()
	draw_hud()
	draw_controls()
	draw_mission_overlay()

	if flash_time > 0.0:
		draw_rect(Rect2(0, 0, 1280, CONTROL_TOP), Color(1, 1, 1, 0.16))


func draw_title_screen():
	draw_rect(Rect2(0, 0, 1280, 720), Color("#040306"))
	var bg_w = float(level_bg.get_width()) * 0.72
	var bg_h = float(level_bg.get_height()) * 0.72
	draw_texture_rect(level_bg, Rect2(0, 0, bg_w, bg_h), false)
	if bg_w < 1280.0:
		draw_texture_rect(level_bg, Rect2(bg_w, 0, bg_w, bg_h), false)
	draw_rect(Rect2(0, 0, 1280, 720), Color(0.01, 0.005, 0.02, 0.50))
	draw_rect(Rect2(0, 0, 1280, 720), Color(1.0, 0.0, 0.45, 0.035))

	var hero_w = 420.0
	var hero_h = hero_w * float(hc_shoot.get_height()) / float(hc_shoot.get_width())
	draw_texture_rect(hc_shoot, Rect2(42, 132, hero_w, hero_h), false)

	draw_string(ThemeDB.fallback_font, Vector2(535, 165), "TACTICAL TERROR DIVISION", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color("#f3efe8"))
	draw_string(ThemeDB.fallback_font, Vector2(530, 258), "TTD:", HORIZONTAL_ALIGNMENT_LEFT, -1, 68, Color("#ff2d95"))
	draw_string(ThemeDB.fallback_font, Vector2(525, 350), "DEATH RUN", HORIZONTAL_ALIGNMENT_LEFT, -1, 92, Color("#8aff2b"))
	draw_string(ThemeDB.fallback_font, Vector2(535, 392), "VHS QUARTER UPRISING", HORIZONTAL_ALIGNMENT_LEFT, -1, 25, Color("#fff04a"))

	draw_rect(Rect2(528, 432, 570, 82), Color("#09070ddd"))
	draw_rect(Rect2(528, 432, 570, 82), Color("#ff2d95"), false, 3.0)
	var pulse = 0.72 + 0.28 * abs(sin(title_pulse * 3.2))
	draw_string(ThemeDB.fallback_font, Vector2(650, 486), "TAP TO DEPLOY", HORIZONTAL_ALIGNMENT_LEFT, -1, 35, Color(0.54, 1.0, 0.17, pulse))

	draw_string(ThemeDB.fallback_font, Vector2(535, 552), "STAGE 01 // VHS QUARTER", HORIZONTAL_ALIGNMENT_LEFT, -1, 19, Color("#f3efe8"))
	draw_string(ThemeDB.fallback_font, Vector2(535, 582), "SURVIVE THE BROADCAST.", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("#ff2d95"))
	draw_string(ThemeDB.fallback_font, Vector2(535, 610), "DESTROY THE SIGNAL. ESCAPE THE FEED.", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("#f3efe8"))

	draw_rect(Rect2(0, 650, 1280, 70), Color("#050508ef"))
	draw_string(ThemeDB.fallback_font, Vector2(34, 692), "TBN LIVE // RATINGS UP // CASUALTY FORECAST: EXCELLENT", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("#ff2d95"))

func draw_level_background():
	draw_rect(Rect2(0, 0, 1280, 720), Color("#07050e"))
	var bg_scale = 0.63
	var bg_w = float(level_bg.get_width()) * bg_scale
	var bg_h = float(level_bg.get_height()) * bg_scale
	var bg_shift = -fmod(camera_x * 0.055, bg_w)
	var bg_y = 100.0
	draw_texture_rect(level_bg, Rect2(bg_shift + get_shake_x() * 0.25, bg_y, bg_w, bg_h), false)
	draw_texture_rect(level_bg, Rect2(bg_shift + bg_w + get_shake_x() * 0.25, bg_y, bg_w, bg_h), false)
	draw_rect(Rect2(0, FLOOR_Y - 22.0, 1280, 47.0), Color("#09070db5"))
	draw_line(Vector2(0, FLOOR_Y), Vector2(1280, FLOOR_Y), Color("#ff2d95"), 2.0)

func draw_level_environment():
	for sector in range(11):
		var base = 250.0 + sector * 2900.0
		if sector % 3 == 0:
			draw_env_region(env_store, base, FLOOR_Y, 350.0)
			draw_env_region(env_skull_billboard, base + 760.0, 400.0, 265.0)
			draw_env_region(env_dumpster, base + 1760.0, FLOOR_Y, 205.0)
			draw_env_region(env_arcade, base + 2440.0, FLOOR_Y, 175.0)
		elif sector % 3 == 1:
			draw_env_region(env_rewind_billboard, base + 120.0, 405.0, 250.0)
			draw_env_region(env_toxic_barrels, base + 980.0, FLOOR_Y, 125.0)
			draw_env_region(env_barricade, base + 1620.0, FLOOR_Y, 235.0)
			draw_env_region(env_crt_stack, base + 2380.0, FLOOR_Y, 150.0)
		else:
			draw_env_region(env_skull_billboard, base + 80.0, 415.0, 235.0)
			draw_env_region(env_store, base + 650.0, FLOOR_Y, 320.0)
			draw_env_region(env_vhs_crates, base + 1780.0, FLOOR_Y, 185.0)
			draw_env_region(env_streetlamp, base + 2440.0, FLOOR_Y, 175.0)

func draw_env_region(src, world_x, bottom_y, width):
	var height = width * src.size.y / src.size.x
	var px = world_x - camera_x + get_shake_x()
	if px < -width - 30.0 or px > 1310.0:
		return
	draw_texture_rect_region(environment_sheet, Rect2(px, bottom_y - height + get_shake_y(), width, height), src)

func draw_relays():
	for i in range(relay_x.size()):
		if not relay_alive[i]:
			continue
		var px = relay_x[i] - camera_x
		if px < -180.0 or px > 1400.0:
			continue
		draw_env_region(env_arcade, relay_x[i], FLOOR_Y, 220.0)
		var pulse = 0.55 + 0.45 * abs(sin(game_time * 5.0 + i))
		draw_circle(Vector2(px + 85.0, FLOOR_Y - 165.0), 58.0, Color(1.0, 0.18, 0.58, 0.06 * pulse))
		draw_line(Vector2(px + 85.0, FLOOR_Y - 215.0), Vector2(px + 85.0, FLOOR_Y - 285.0), Color(0.54, 1.0, 0.17, pulse), 3.0)
		draw_string(ThemeDB.fallback_font, Vector2(px - 10.0, FLOOR_Y - 230.0), "TDI SIGNAL NODE " + str(i + 1), HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("#fff04a"))
		draw_rect(Rect2(px - 15.0, FLOOR_Y - 210.0, 170.0, 16.0), Color("#211019"))
		var maxhp = 8.0
		if i == 1:
			maxhp = 10.0
		draw_rect(Rect2(px - 15.0, FLOOR_Y - 210.0, 170.0 * relay_hp[i] / maxhp, 16.0), Color("#8aff2b"))

func draw_pickups():
	for i in range(pickup_x.size()):
		if not pickup_alive[i]:
			continue
		if pickup_type[i] == 0:
			draw_env_region(env_tape, pickup_x[i], FLOOR_Y, 62.0)
		else:
			draw_env_region(env_toxic_barrels, pickup_x[i], FLOOR_Y, 62.0)

func get_enemy_region(i):
	var t = enemy_type[i]
	var attacking = enemy_attack_timer[i] > 0.0
	var chasing = abs(player_x - enemy_x[i]) < 430.0
	if t == 0:
		if attacking:
			return punk_attack_region
		if chasing:
			return punk_run_region
		return punk_idle_region
	elif t == 1:
		if attacking:
			return tdi_attack_region
		if chasing:
			return tdi_run_region
		return tdi_idle_region
	else:
		if attacking:
			return toxic_attack_region
		if chasing:
			return toxic_run_region
		return toxic_idle_region

func draw_enemies():
	for i in range(enemy_x.size()):
		if not enemy_alive[i]:
			continue
		var px = enemy_x[i] - camera_x + get_shake_x()
		if px < -180.0 or px > 1400.0:
			continue
		var src = get_enemy_region(i)
		var width = 265.0
		if enemy_type[i] == 1:
			width = 300.0
		elif enemy_type[i] == 2:
			width = 285.0
		var height = width * src.size.y / src.size.x
		var facing_left = player_x < enemy_x[i]
		draw_sheet_region(enemy_sheet, src, px - width * 0.42, FLOOR_Y - height + get_shake_y(), width, height, facing_left)

func draw_sheet_region(tex, src, x, y, width, height, flip_x):
	if flip_x:
		draw_set_transform(Vector2(x + width, 0), 0.0, Vector2(-1.0, 1.0))
		draw_texture_rect_region(tex, Rect2(0, y, width, height), src)
		draw_set_transform(Vector2(0, 0), 0.0, Vector2(1.0, 1.0))
	else:
		draw_texture_rect_region(tex, Rect2(x, y, width, height), src)

func draw_bullets():
	if muzzle_flash_timer > 0.0:
		var mx = player_x - camera_x
		var my = player_y + 38.0
		if player_facing > 0.0:
			mx += 118.0
		else:
			mx -= 42.0
		var ma = muzzle_flash_timer / 0.055
		draw_circle(Vector2(mx, my), 18.0 * ma, Color(1.0, 0.95, 0.25, 0.55 * ma))
		draw_line(Vector2(mx, my), Vector2(mx + player_facing * 45.0 * ma, my), Color(1.0, 0.18, 0.58, ma), 7.0)

	for i in range(bullet_x.size()):
		if not bullet_alive[i]:
			continue
		var px = bullet_x[i] - camera_x
		if px < -30.0 or px > 1310.0:
			continue
		draw_line(Vector2(px - bullet_dir[i] * 20.0, bullet_y[i] + 2.0), Vector2(px + bullet_dir[i] * 26.0, bullet_y[i] + 2.0), Color("#fff04a"), 4.0)
		draw_line(Vector2(px - bullet_dir[i] * 34.0, bullet_y[i] + 2.0), Vector2(px - bullet_dir[i] * 4.0, bullet_y[i] + 2.0), Color(1.0, 0.18, 0.58, 0.45), 2.0)

func draw_boss():
	if not boss_started or boss_hp <= 0:
		return
	var px = boss_x - camera_x
	if px < -200.0 or px > 1450.0:
		return
	var src = tdi_attack_region
	var width = 390.0
	var height = width * src.size.y / src.size.x
	draw_sheet_region(enemy_sheet, src, px - 90.0, FLOOR_Y - height, width, height, player_x < boss_x)
	draw_rect(Rect2(880, 178, 350, 18), Color("#211019"))
	draw_rect(Rect2(880, 178, 350.0 * boss_hp / 18.0, 18), Color("#ff2d95"))
	draw_string(ThemeDB.fallback_font, Vector2(880, 168), "TBN EXECUTIONER", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("#f3efe8"))

func draw_player():
	var px = player_x - camera_x + get_shake_x()
	var tex = hc_idle
	if stage_finished:
		tex = hc_win
	elif hurt_timer > 0.0:
		tex = hc_hurt
	elif shoot_anim_timer > 0.0:
		tex = hc_shoot
	elif smash_timer > 0.0:
		tex = hc_smash
	elif not player_grounded:
		tex = hc_jump
	elif abs(player_vx) > 35.0:
		var frame = int(run_anim_time * 10.0) % 3
		if frame == 0:
			tex = hc_run1
		elif frame == 1:
			tex = hc_run2
		else:
			tex = hc_run3
	var width = 118.0
	if not player_grounded:
		width = 132.0
	var height = width * float(tex.get_height()) / float(tex.get_width())
	var bottom = FLOOR_Y
	if not player_grounded:
		bottom = player_y + 126.0
	if player_facing < 0.0:
		draw_set_transform(Vector2(px + 80.0, 0), 0.0, Vector2(-1.0, 1.0))
		draw_texture_rect(tex, Rect2(0, bottom - height + get_shake_y(), width, height), false)
		draw_set_transform(Vector2(0, 0), 0.0, Vector2(1.0, 1.0))
	else:
		draw_texture_rect(tex, Rect2(px - 38.0, bottom - height + get_shake_y(), width, height), false)

	if jump_burst_time > 0.0:
		var a = jump_burst_time / 0.18
		draw_circle(Vector2(px + 5.0, FLOOR_Y - 5.0), 24.0 * a, Color(1.0, 0.94, 0.25, 0.18 * a))
		draw_circle(Vector2(px + 54.0, FLOOR_Y - 5.0), 17.0 * a, Color(1.0, 0.18, 0.58, 0.16 * a))
	if landing_burst_time > 0.0:
		var la = landing_burst_time / 0.20
		draw_line(Vector2(px - 42.0, FLOOR_Y - 2.0), Vector2(px + 112.0, FLOOR_Y - 2.0), Color(0.54, 1.0, 0.17, 0.65 * la), 5.0)
		draw_circle(Vector2(px + 34.0, FLOOR_Y - 3.0), 42.0 * la, Color(1.0, 0.18, 0.58, 0.10 * la))


func draw_foreground():
	# Fast foreground layer creates depth without adding new art assets.
	for sector in range(11):
		var base = 420.0 + sector * 2900.0
		var fx = base - camera_x * 1.08 + get_shake_x() * 1.2
		if fx > -280.0 and fx < 1360.0:
			draw_texture_rect_region(environment_sheet, Rect2(fx, 500.0, 250.0, 210.0), env_vhs_crates)
		var lx = base + 1650.0 - camera_x * 1.05 + get_shake_x()
		if lx > -260.0 and lx < 1360.0:
			draw_texture_rect_region(environment_sheet, Rect2(lx, 330.0, 205.0, 280.0), env_streetlamp)

func draw_hud():
	draw_rect(Rect2(0, 0, 1280, 108), Color("#050508f5"))
	draw_texture_rect_region(hud_sheet, Rect2(18, 10, 250, 82), hud_stage)
	draw_texture_rect_region(hud_sheet, Rect2(276, 10, 205, 82), hud_score)
	draw_texture_rect_region(hud_sheet, Rect2(490, 10, 315, 82), hud_health)
	draw_texture_rect_region(hud_sheet, Rect2(815, 10, 185, 82), hud_lives)
	draw_texture_rect_region(hud_sheet, Rect2(1008, 10, 254, 82), hud_tbn)
	draw_rect(Rect2(340, 47, 124, 31), Color("#09080d"))
	draw_string(ThemeDB.fallback_font, Vector2(347, 72), str(score), HORIZONTAL_ALIGNMENT_LEFT, -1, 23, Color("#f3efe8"))
	draw_rect(Rect2(630, 51, 145, 21), Color("#211019"))
	draw_rect(Rect2(630, 51, 145.0 * float(player_health) / 100.0, 21), Color("#ff2d95"))
	draw_rect(Rect2(858, 49, 106, 27), Color("#09080d"))
	draw_string(ThemeDB.fallback_font, Vector2(874, 70), "x " + str(player_lives), HORIZONTAL_ALIGNMENT_LEFT, -1, 21, Color("#8aff2b"))
	draw_rect(Rect2(650, 79, 155, 22), Color("#09080d"))
	draw_rect(Rect2(650, 79, 155, 22), Color("#fff04a"), false, 1.0)
	draw_string(ThemeDB.fallback_font, Vector2(661, 96), "AMMO // " + str(ammo), HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("#fff04a"))
	if combo > 1:
		draw_rect(Rect2(1010, 82, 250, 21), Color("#09080d"))
		draw_string(ThemeDB.fallback_font, Vector2(1020, 98), "KILL STREAK x" + str(combo), HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("#ff2d95"))
	draw_texture_rect_region(hud_sheet, Rect2(18, 112, 680, 53), hud_ticker)
	draw_rect(Rect2(122, 124, 555, 27), Color("#08070b"))
	var ticker = get_objective_text()
	draw_string(ThemeDB.fallback_font, Vector2(132, 146), ticker, HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("#f3efe8"))

func get_objective_text():
	if stage_finished:
		return "MISSION COMPLETE // VHS QUARTER SURVIVED."
	if boss_started:
		return "OBJECTIVE // EXECUTE THE EXECUTIONER."
	if relay_alive[0]:
		return "OBJECTIVE // DESTROY TDI RELAY 1."
	if relay_alive[1]:
		return "OBJECTIVE // DESTROY TDI RELAY 2."
	return "OBJECTIVE // REACH VHS PALACE."

func draw_controls():
	draw_rect(Rect2(0, CONTROL_TOP, 1280, 95), Color("#060609f2"))
	draw_texture_rect_region(hud_sheet, Rect2(18, 637, 155, 72), hud_left)
	draw_texture_rect_region(hud_sheet, Rect2(185, 637, 155, 72), hud_right)
	draw_texture_rect_region(hud_sheet, Rect2(780, 637, 145, 72), hud_jump)
	draw_texture_rect_region(hud_sheet, Rect2(935, 637, 145, 72), hud_smash)
	draw_rect(Rect2(1090, 637, 175, 72), Color("#0b0b10"))
	draw_rect(Rect2(1090, 637, 175, 72), Color("#ff2d95"), false, 3.0)
	draw_rect(Rect2(1097, 644, 161, 58), Color("#fff04a"), false, 1.0)
	draw_string(ThemeDB.fallback_font, Vector2(1110, 682), "DRRRT", HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color("#fff04a"))

func draw_mission_overlay():
	if stage_finished:
		draw_results_panel()
		return

	if encounter_text_timer > 0.0 and intro_timer <= 0.0:
		var alpha = min(1.0, encounter_text_timer)
		draw_rect(Rect2(335, 170, 610, 70), Color(0.02, 0.01, 0.04, 0.88 * alpha))
		draw_rect(Rect2(335, 170, 610, 70), Color("#ff2d95"), false, 3.0)
		draw_string(ThemeDB.fallback_font, Vector2(365, 215), encounter_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 23, Color(0.54, 1.0, 0.17, alpha))

	if intro_timer > 0.0:
		draw_rect(Rect2(0, 0, 1280, 625), Color("#050508e8"))
		draw_string(ThemeDB.fallback_font, Vector2(110, 245), "TTD: DEATH RUN", HORIZONTAL_ALIGNMENT_LEFT, -1, 58, Color("#f3efe8"))
		draw_string(ThemeDB.fallback_font, Vector2(112, 300), "STAGE 01 // VHS QUARTER", HORIZONTAL_ALIGNMENT_LEFT, -1, 30, Color("#ff2d95"))
		draw_string(ThemeDB.fallback_font, Vector2(112, 355), "MISSION // CROSS THE QUARTER. KILL BOTH SIGNALS. REACH VHS PALACE.", HORIZONTAL_ALIGNMENT_LEFT, -1, 21, Color("#8aff2b"))
	elif mission_text_timer > 0.0:
		draw_rect(Rect2(370, 190, 540, 92), Color("#050508dc"))
		draw_rect(Rect2(370, 190, 540, 92), Color("#ff2d95"), false, 2.0)
		draw_string(ThemeDB.fallback_font, Vector2(395, 245), get_objective_text(), HORIZONTAL_ALIGNMENT_LEFT, -1, 19, Color("#f3efe8"))


func draw_results_panel():
	draw_rect(Rect2(0, 0, 1280, 625), Color("#050508e8"))
	draw_rect(Rect2(225, 115, 830, 430), Color("#09080df2"))
	draw_rect(Rect2(225, 115, 830, 430), Color("#8aff2b"), false, 3.0)
	draw_string(ThemeDB.fallback_font, Vector2(285, 180), "MISSION COMPLETE", HORIZONTAL_ALIGNMENT_LEFT, -1, 44, Color("#8aff2b"))
	draw_string(ThemeDB.fallback_font, Vector2(285, 220), "STAGE 01 // VHS QUARTER", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color("#ff2d95"))

	var accuracy = 0
	if shots_fired > 0:
		accuracy = int(round(float(shots_hit) / float(shots_fired) * 100.0))

	draw_string(ThemeDB.fallback_font, Vector2(305, 292), "SCORE", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("#f3efe8"))
	draw_string(ThemeDB.fallback_font, Vector2(690, 292), str(score), HORIZONTAL_ALIGNMENT_LEFT, -1, 30, Color("#fff04a"))
	draw_string(ThemeDB.fallback_font, Vector2(305, 340), "HOSTILES ERASED", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("#f3efe8"))
	draw_string(ThemeDB.fallback_font, Vector2(690, 340), str(kills), HORIZONTAL_ALIGNMENT_LEFT, -1, 28, Color("#ff2d95"))
	draw_string(ThemeDB.fallback_font, Vector2(305, 388), "BEST KILL STREAK", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("#f3efe8"))
	draw_string(ThemeDB.fallback_font, Vector2(690, 388), "x" + str(best_combo), HORIZONTAL_ALIGNMENT_LEFT, -1, 28, Color("#8aff2b"))
	draw_string(ThemeDB.fallback_font, Vector2(305, 436), "DRRRT ACCURACY", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("#f3efe8"))
	draw_string(ThemeDB.fallback_font, Vector2(690, 436), str(accuracy) + "%", HORIZONTAL_ALIGNMENT_LEFT, -1, 28, Color("#fff04a"))

	var grade = "C"
	if score >= 30000:
		grade = "B"
	if score >= 42000:
		grade = "A"
	if score >= 55000:
		grade = "S"
	draw_string(ThemeDB.fallback_font, Vector2(875, 388), grade, HORIZONTAL_ALIGNMENT_LEFT, -1, 92, Color("#ff2d95"))
	draw_string(ThemeDB.fallback_font, Vector2(305, 500), "GRIM LEDGER: SURVIVAL REMAINS BULLISH.", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("#f3efe8"))

