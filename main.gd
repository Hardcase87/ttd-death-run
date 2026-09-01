extends Node2D

const WORLD_W = 7200.0
const FLOOR_Y = 600.0
const CONTROL_TOP = 625.0

var hc_idle = preload("res://assets/sprites/hardcase/hardcase_01.png")
var hc_run1 = preload("res://assets/sprites/hardcase/hardcase_02.png")
var hc_run2 = preload("res://assets/sprites/hardcase/hardcase_03.png")
var hc_run3 = preload("res://assets/sprites/hardcase/hardcase_04.png")
var hc_jump = preload("res://assets/sprites/hardcase/hardcase_05.png")
var hc_smash = preload("res://assets/sprites/hardcase/hardcase_08.png")
var hc_hurt = preload("res://assets/sprites/hardcase/hardcase_09.png")
var hc_win = preload("res://assets/sprites/hardcase/hardcase_10.png")

var level_bg = preload("res://assets/backgrounds/vhs_quarter_neon_background.png")
var environment_sheet = preload("res://assets/environment/neon_vhs_palace_asset_sheet.png")
var enemy_sheet = preload("res://assets/enemies/neon_cyberpunk_enemy_sprite_sheet.png")
var hud_sheet = preload("res://assets/hud/neon_vhs_cyberpunk_hud_asset_sheet.png")

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
var smash_timer = 0.0
var hurt_timer = 0.0
var stage_finished = false

var camera_x = 0.0
var shake_time = 0.0
var shake_power = 0.0
var flash_time = 0.0
var score = 0
var checkpoint = 0.0
var game_time = 0.0
var run_anim_time = 0.0

var touch_left = false
var touch_right = false
var touch_jump = false
var touch_smash = false
var active_touch_left = -1
var active_touch_right = -1
var active_touch_jump = -1
var active_touch_smash = -1

var enemy_home = [1100.0, 2050.0, 3020.0, 4100.0, 5220.0, 6420.0]
var enemy_x = [1100.0, 2050.0, 3020.0, 4100.0, 5220.0, 6420.0]
var enemy_type = [0, 1, 2, 0, 1, 2]
var enemy_hp = [2, 3, 3, 3, 4, 4]
var enemy_alive = [true, true, true, true, true, true]
var enemy_attack_timer = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]

var prop_x = [820.0, 1580.0, 2470.0, 3380.0, 4400.0, 5580.0, 6760.0]
var prop_kind = [0, 1, 2, 3, 1, 0, 2]
var prop_alive = [true, true, true, true, true, true, true]

func _ready():
	queue_redraw()

func _input(event):
	if event is InputEventScreenTouch:
		var pos = event.position
		if event.pressed:
			if Rect2(18, 637, 175, 72).has_point(pos):
				touch_left = true
				active_touch_left = event.index
			elif Rect2(205, 637, 175, 72).has_point(pos):
				touch_right = true
				active_touch_right = event.index
			elif Rect2(910, 637, 170, 72).has_point(pos):
				touch_jump = true
				active_touch_jump = event.index
			elif Rect2(1092, 637, 170, 72).has_point(pos):
				touch_smash = true
				active_touch_smash = event.index
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

func _process(delta):
	game_time += delta
	run_anim_time += delta
	shake_time = max(0.0, shake_time - delta)
	flash_time = max(0.0, flash_time - delta)

	for i in range(enemy_attack_timer.size()):
		enemy_attack_timer[i] = max(0.0, enemy_attack_timer[i] - delta)

	handle_input(delta)
	update_player(delta)
	update_enemies(delta)
	update_props()

	var target_camera = clamp(player_x - 360.0, 0.0, WORLD_W - 1280.0)
	camera_x = lerp(camera_x, target_camera, min(1.0, delta * 6.5))
	queue_redraw()

func handle_input(delta):
	if stage_finished:
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
		player_vy = -720.0
		player_grounded = false

	var smash_pressed = Input.is_action_just_pressed("smash")
	if touch_smash:
		smash_pressed = true
		touch_smash = false

	if smash_pressed and smash_timer <= 0.0:
		smash_timer = 0.30

func update_player(delta):
	smash_timer = max(0.0, smash_timer - delta)
	hurt_timer = max(0.0, hurt_timer - delta)

	player_vy += 1900.0 * delta
	player_x += player_vx * delta
	player_y += player_vy * delta
	player_x = clamp(player_x, 60.0, WORLD_W - 80.0)

	if player_y >= FLOOR_Y - 126.0:
		player_y = FLOOR_Y - 126.0
		player_vy = 0.0
		player_grounded = true

	if player_x > checkpoint + 1500.0:
		checkpoint = player_x

	if player_x >= WORLD_W - 250.0 and not stage_finished:
		stage_finished = true
		score += 5000
		kick_camera(0.25, 10.0)

func update_enemies(delta):
	for i in range(enemy_x.size()):
		if not enemy_alive[i]:
			continue

		var dx = player_x - enemy_x[i]

		if abs(dx) < 430.0:
			var enemy_dir = 1.0
			if dx < 0.0:
				enemy_dir = -1.0
			enemy_x[i] += enemy_dir * 92.0 * delta
		else:
			enemy_x[i] = move_toward(enemy_x[i], enemy_home[i], 60.0 * delta)

		enemy_x[i] = clamp(enemy_x[i], enemy_home[i] - 180.0, enemy_home[i] + 180.0)

		var touching = abs(player_x - enemy_x[i]) < 82.0 and abs((player_y + 60.0) - (FLOOR_Y - 62.0)) < 100.0

		if touching:
			enemy_attack_timer[i] = 0.25
			if smash_timer > 0.0:
				enemy_hp[i] -= 1
				enemy_x[i] += player_facing * 90.0
				kick_camera(0.14, 9.0)
				flash_time = 0.06
				if enemy_hp[i] <= 0:
					enemy_alive[i] = false
					score += 500
					kick_camera(0.22, 14.0)
					flash_time = 0.10
			elif hurt_timer <= 0.0:
				player_health -= 10
				hurt_timer = 0.8
				player_vx = -player_facing * 250.0
				kick_camera(0.12, 7.0)
				flash_time = 0.05
				if player_health <= 0:
					lose_life()

func update_props():
	if smash_timer <= 0.0:
		return

	for i in range(prop_x.size()):
		if not prop_alive[i]:
			continue
		if abs(player_x - prop_x[i]) < 120.0:
			prop_alive[i] = false
			score += 150
			kick_camera(0.18, 11.0)
			flash_time = 0.08

func kick_camera(duration, power):
	shake_time = duration
	shake_power = power

func lose_life():
	player_lives -= 1
	player_health = 100
	player_x = max(220.0, checkpoint - 250.0)
	player_y = FLOOR_Y - 126.0
	kick_camera(0.30, 16.0)

	if player_lives < 0:
		player_lives = 3
		score = 0
		checkpoint = 0.0
		player_x = 220.0

func get_shake_x():
	if shake_time <= 0.0:
		return 0.0
	return sin(game_time * 87.0) * shake_power

func get_shake_y():
	if shake_time <= 0.0:
		return 0.0
	return cos(game_time * 113.0) * shake_power * 0.55

func _draw():
	draw_level_background()
	draw_level_environment()
	draw_props()
	draw_enemies()
	draw_player()
	draw_hud()
	draw_controls()

	if flash_time > 0.0:
		draw_rect(Rect2(0, 0, 1280, CONTROL_TOP), Color(1, 1, 1, 0.16))

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
	draw_env_region(env_store, 150.0, FLOOR_Y, 355.0)
	draw_env_region(env_skull_billboard, 980.0, 405.0, 280.0)
	draw_env_region(env_rewind_billboard, 1820.0, 395.0, 250.0)
	draw_env_region(env_tape_boost, 2550.0, FLOOR_Y, 150.0)
	draw_env_region(env_toxic_barrels, 3260.0, FLOOR_Y, 150.0)
	draw_env_region(env_dumpster, 3930.0, FLOOR_Y, 230.0)
	draw_env_region(env_crt_stack, 4700.0, FLOOR_Y, 155.0)
	draw_env_region(env_arcade, 5350.0, FLOOR_Y, 180.0)
	draw_env_region(env_barricade, 6040.0, FLOOR_Y, 230.0)
	draw_env_region(env_streetlamp, 6650.0, FLOOR_Y, 165.0)

	draw_env_region(env_vhs_crates, 1420.0, FLOOR_Y, 120.0)
	draw_env_region(env_tape, 2290.0, FLOOR_Y, 70.0)
	draw_env_region(env_tape, 4480.0, FLOOR_Y, 70.0)

func draw_env_region(src, world_x, bottom_y, width):
	var height = width * src.size.y / src.size.x
	var px = world_x - camera_x + get_shake_x()
	if px < -width - 30.0 or px > 1310.0:
		return
	var dest = Rect2(px, bottom_y - height + get_shake_y(), width, height)
	draw_texture_rect_region(environment_sheet, dest, src)

func draw_props():
	for i in range(prop_x.size()):
		if not prop_alive[i]:
			continue

		if prop_kind[i] == 0:
			draw_env_region(env_toxic_barrels, prop_x[i], FLOOR_Y, 76.0)
		elif prop_kind[i] == 1:
			draw_env_region(env_vhs_crates, prop_x[i], FLOOR_Y, 92.0)
		elif prop_kind[i] == 2:
			draw_env_region(env_tape, prop_x[i], FLOOR_Y, 58.0)
		else:
			draw_env_region(env_crt_stack, prop_x[i], FLOOR_Y, 92.0)

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
		var width = 135.0
		if enemy_type[i] == 1:
			width = 140.0
		elif enemy_type[i] == 2:
			width = 145.0

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

func draw_player():
	var px = player_x - camera_x + get_shake_x()
	var tex = hc_idle

	if stage_finished:
		tex = hc_win
	elif hurt_timer > 0.0:
		tex = hc_hurt
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
	var height = width * float(tex.get_height()) / float(tex.get_width())
	var bottom = FLOOR_Y
	if not player_grounded:
		bottom = player_y + 126.0

	var flip_player = player_facing < 0.0
	if flip_player:
		draw_set_transform(Vector2(px + 80.0, 0), 0.0, Vector2(-1.0, 1.0))
		draw_texture_rect(tex, Rect2(0, bottom - height + get_shake_y(), width, height), false)
		draw_set_transform(Vector2(0, 0), 0.0, Vector2(1.0, 1.0))
	else:
		draw_texture_rect(tex, Rect2(px - 38.0, bottom - height + get_shake_y(), width, height), false)

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

	draw_rect(Rect2(905, 42, 78, 35), Color("#08090b"))
	draw_string(ThemeDB.fallback_font, Vector2(914, 69), "x " + str(player_lives), HORIZONTAL_ALIGNMENT_LEFT, -1, 23, Color("#8aff2b"))

	draw_texture_rect_region(hud_sheet, Rect2(18, 112, 600, 53), hud_ticker)
	draw_rect(Rect2(122, 124, 475, 27), Color("#08070b"))

	var ticker = "GRIM LEDGER: SURVIVAL REMAINS BULLISH."
	if stage_finished:
		ticker = "HARDCASE SURVIVED. SHAREHOLDERS FURIOUS."

	draw_string(ThemeDB.fallback_font, Vector2(132, 146), ticker, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("#f3efe8"))

func draw_controls():
	draw_rect(Rect2(0, CONTROL_TOP, 1280, 95), Color("#060609f2"))
	draw_line(Vector2(0, CONTROL_TOP), Vector2(1280, CONTROL_TOP), Color("#ff2d95"), 1.0)

	draw_texture_rect_region(hud_sheet, Rect2(18, 635, 175, 72), hud_left)
	draw_texture_rect_region(hud_sheet, Rect2(205, 635, 175, 72), hud_right)
	draw_texture_rect_region(hud_sheet, Rect2(910, 635, 170, 72), hud_jump)
	draw_texture_rect_region(hud_sheet, Rect2(1092, 635, 170, 72), hud_smash)
