extends Node2D

const WORLD_W = 23800.0
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
	950.0, 1700.0, 2550.0, 3500.0, 4450.0, 5350.0,
	6550.0, 7350.0, 8250.0, 9300.0, 10450.0, 11400.0,
	12700.0, 13600.0, 14550.0, 15700.0, 16850.0, 17800.0,
	19100.0, 19950.0, 20750.0, 21650.0
]
var enemy_x = [
	950.0, 1700.0, 2550.0, 3500.0, 4450.0, 5350.0,
	6550.0, 7350.0, 8250.0, 9300.0, 10450.0, 11400.0,
	12700.0, 13600.0, 14550.0, 15700.0, 16850.0, 17800.0,
	19100.0, 19950.0, 20750.0, 21650.0
]
var enemy_type = [0,0,1,2,0,1, 2,0,1,0,2,1, 0,2,1,0,1,2, 0,1,2,1]
var enemy_hp = [2,2,3,3,2,3, 3,3,4,3,4,4, 3,4,4,3,4,5, 4,5,5,5]
var enemy_alive = [
	true,true,true,true,true,true,true,true,true,true,true,
	true,true,true,true,true,true,true,true,true,true,true
]
var enemy_attack_timer = [
	0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,
	0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0
]

var relay_x = [7850.0, 15850.0]
var relay_hp = [8, 10]
var relay_alive = [true, true]

var pickup_x = [2900.0, 6200.0, 10100.0, 13300.0, 17600.0, 20400.0]
var pickup_type = [0, 1, 0, 1, 0, 1]
var pickup_alive = [true,true,true,true,true,true]

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
		player_vy = -920.0
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
	ammo -= 1
	var bx = player_x + 78.0
	if player_facing < 0.0:
		bx = player_x - 20.0
	bullet_x.append(bx)
	bullet_y.append(player_y + 55.0)
	bullet_dir.append(player_facing)
	bullet_alive.append(true)
	play_sfx(sfx_shoot, -8.0)
	kick_camera(0.035, 2.0)

func update_player(delta):
	smash_timer = max(0.0, smash_timer - delta)
	hurt_timer = max(0.0, hurt_timer - delta)

	var was_grounded = player_grounded
	player_vy += 2300.0 * delta
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
		score += 10000
		play_sfx(sfx_relay, -2.0)

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
			if abs(bullet_x[b] - enemy_x[i]) < 78.0 and abs(bullet_y[b] - (FLOOR_Y - 70.0)) < 85.0:
				enemy_hp[i] -= 1
				bullet_alive[b] = false
				score += 50
				play_sfx(sfx_hit, -9.0)
				flash_time = 0.025
				if enemy_hp[i] <= 0:
					enemy_alive[i] = false
					score += 450
					play_sfx(sfx_death, -6.0)
					kick_camera(0.12, 7.0)

		for r in range(relay_x.size()):
			if relay_alive[r] and bullet_alive[b] and abs(bullet_x[b] - relay_x[r]) < 75.0:
				relay_hp[r] -= 1
				bullet_alive[b] = false
				score += 75
				if relay_hp[r] <= 0:
					relay_alive[r] = false
					score += 1500
					play_sfx(sfx_relay, -3.0)
					kick_camera(0.35, 16.0)

		if boss_started and boss_hp > 0 and bullet_alive[b] and abs(bullet_x[b] - 22950.0) < 90.0:
			boss_hp -= 1
			bullet_alive[b] = false
			score += 100
			play_sfx(sfx_hit, -7.0)
			if boss_hp <= 0:
				score += 5000
				play_sfx(sfx_death, -1.0)
				kick_camera(0.6, 22.0)

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
		var touching = abs(player_x - enemy_x[i]) < 104.0 and abs((player_y + 60.0) - (FLOOR_Y - 62.0)) < 100.0

		if touching:
			enemy_attack_timer[i] = 0.25
			if smash_timer > 0.0:
				enemy_hp[i] -= 2
				enemy_x[i] += player_facing * 105.0
				kick_camera(0.14, 9.0)
				flash_time = 0.06
				if enemy_hp[i] <= 0:
					enemy_alive[i] = false
					score += 500
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
	if player_x > 6200.0 and checkpoint_index < 1:
		checkpoint_index = 1
		checkpoint = 6200.0
		mission_text_timer = 2.5
	if player_x > 12200.0 and checkpoint_index < 2:
		checkpoint_index = 2
		checkpoint = 12200.0
		mission_text_timer = 2.5
	if player_x > 18400.0 and checkpoint_index < 3:
		checkpoint_index = 3
		checkpoint = 18400.0
		mission_text_timer = 2.5

func update_boss():
	if player_x > 22150.0 and not boss_started:
		if not relay_alive[0] and not relay_alive[1]:
			boss_started = true
			mission_text_timer = 4.0
			play_sfx(sfx_boss, -2.0)
		else:
			player_x = min(player_x, 22120.0)

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
	draw_player()
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
	for sector in range(8):
		var base = 250.0 + sector * 2900.0
		draw_env_region(env_store, base, FLOOR_Y, 335.0)
		draw_env_region(env_skull_billboard, base + 720.0, 410.0, 245.0)
		draw_env_region(env_rewind_billboard, base + 1320.0, 405.0, 220.0)
		draw_env_region(env_dumpster, base + 1880.0, FLOOR_Y, 190.0)
		draw_env_region(env_crt_stack, base + 2320.0, FLOOR_Y, 130.0)
		if sector % 2 == 0:
			draw_env_region(env_arcade, base + 2620.0, FLOOR_Y, 155.0)
		else:
			draw_env_region(env_barricade, base + 2620.0, FLOOR_Y, 205.0)

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
		draw_env_region(env_arcade, relay_x[i], FLOOR_Y, 185.0)
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
		var width = 188.0
		if enemy_type[i] == 1:
			width = 198.0
		elif enemy_type[i] == 2:
			width = 208.0
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
	for i in range(bullet_x.size()):
		if not bullet_alive[i]:
			continue
		var px = bullet_x[i] - camera_x
		if px < -30.0 or px > 1310.0:
			continue
		draw_rect(Rect2(px, bullet_y[i], 22.0, 5.0), Color("#fff04a"))
		draw_rect(Rect2(px - bullet_dir[i] * 10.0, bullet_y[i] + 1.0, 10.0, 3.0), Color("#ff2d95"))

func draw_boss():
	if not boss_started or boss_hp <= 0:
		return
	var px = 22950.0 - camera_x
	if px < -200.0 or px > 1450.0:
		return
	var src = tdi_attack_region
	var width = 270.0
	var height = width * src.size.y / src.size.x
	draw_sheet_region(enemy_sheet, src, px - 90.0, FLOOR_Y - height, width, height, player_x < 22950.0)
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
	draw_string(ThemeDB.fallback_font, Vector2(865, 72), "x " + str(player_lives), HORIZONTAL_ALIGNMENT_LEFT, -1, 23, Color("#8aff2b"))
	draw_string(ThemeDB.fallback_font, Vector2(1020, 99), "AMMO " + str(ammo), HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("#fff04a"))
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
	draw_rect(Rect2(1090, 637, 175, 72), Color("#fff04a"), false, 3.0)
	draw_string(ThemeDB.fallback_font, Vector2(1110, 682), "DRRRT", HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color("#fff04a"))

func draw_mission_overlay():
	if intro_timer > 0.0:
		draw_rect(Rect2(0, 0, 1280, 625), Color("#050508e8"))
		draw_string(ThemeDB.fallback_font, Vector2(110, 245), "TTD: DEATH RUN", HORIZONTAL_ALIGNMENT_LEFT, -1, 58, Color("#f3efe8"))
		draw_string(ThemeDB.fallback_font, Vector2(112, 300), "STAGE 01 // VHS QUARTER", HORIZONTAL_ALIGNMENT_LEFT, -1, 30, Color("#ff2d95"))
		draw_string(ThemeDB.fallback_font, Vector2(112, 355), "MISSION // KILL THE SIGNAL. BREAK THE FEED. REACH VHS PALACE.", HORIZONTAL_ALIGNMENT_LEFT, -1, 21, Color("#8aff2b"))
	elif mission_text_timer > 0.0:
		draw_rect(Rect2(370, 190, 540, 92), Color("#050508dc"))
		draw_rect(Rect2(370, 190, 540, 92), Color("#ff2d95"), false, 2.0)
		draw_string(ThemeDB.fallback_font, Vector2(395, 245), get_objective_text(), HORIZONTAL_ALIGNMENT_LEFT, -1, 19, Color("#f3efe8"))
