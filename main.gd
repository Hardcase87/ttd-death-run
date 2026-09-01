extends Node2D

const WORLD_W = 7200.0
const FLOOR_Y = 610.0

# HARDCASE
var hc_idle = preload("res://assets/sprites/hardcase/hardcase_01.png")
var hc_run1 = preload("res://assets/sprites/hardcase/hardcase_02.png")
var hc_run2 = preload("res://assets/sprites/hardcase/hardcase_03.png")
var hc_run3 = preload("res://assets/sprites/hardcase/hardcase_04.png")
var hc_jump = preload("res://assets/sprites/hardcase/hardcase_05.png")
var hc_smash = preload("res://assets/sprites/hardcase/hardcase_08.png")
var hc_hurt = preload("res://assets/sprites/hardcase/hardcase_09.png")
var hc_win = preload("res://assets/sprites/hardcase/hardcase_10.png")

# ENEMIES / PICKUPS
var enemy_mutant_idle = preload("res://assets/sprites/enemies/enemy_02.png")
var enemy_mutant_run = preload("res://assets/sprites/enemies/enemy_03.png")
var medkit_tex = preload("res://assets/sprites/enemies/enemy_07.png")
var ammo_tex = preload("res://assets/sprites/enemies/enemy_08.png")
var mine_tex = preload("res://assets/sprites/enemies/enemy_09.png")

# VHS QUARTER ENVIRONMENT
var vhs_sign = preload("res://assets/environment/vhs_quarter/vhs_01.png")
var vhs_store = preload("res://assets/environment/vhs_quarter/vhs_02.png")
var no_refunds = preload("res://assets/environment/vhs_quarter/vhs_03.png")
var toxic_barrel = preload("res://assets/environment/vhs_quarter/vhs_04.png")
var hazard_barrel = preload("res://assets/environment/vhs_quarter/vhs_05.png")
var vhs_billboard = preload("res://assets/environment/vhs_quarter/vhs_06.png")
var crt_stack = preload("res://assets/environment/vhs_quarter/vhs_07.png")
var tape_boost = preload("res://assets/environment/vhs_quarter/vhs_08.png")
var tape_pile = preload("res://assets/environment/vhs_quarter/vhs_09.png")
var dumpster = preload("res://assets/environment/vhs_quarter/vhs_10.png")
var platform_long = preload("res://assets/environment/vhs_quarter/vhs_11.png")
var platform_short = preload("res://assets/environment/vhs_quarter/vhs_12.png")

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
var win_timer = 0.0

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

var enemy_x = [1080.0, 1750.0, 2520.0, 3560.0, 4700.0, 5940.0]
var enemy_hp = [2, 2, 3, 3, 4, 4]
var enemy_alive = [true, true, true, true, true, true]

var prop_x = [780.0, 1420.0, 2140.0, 3010.0, 3970.0, 5180.0, 6490.0]
var prop_kind = [0, 1, 2, 1, 3, 0, 2]
var prop_alive = [true, true, true, true, true, true, true]

func _ready():
	queue_redraw()

func _input(event):
	if event is InputEventScreenTouch:
		var pos = event.position
		if event.pressed:
			if Rect2(18, 630, 150, 72).has_point(pos):
				touch_left = true
				active_touch_left = event.index
			elif Rect2(180, 630, 150, 72).has_point(pos):
				touch_right = true
				active_touch_right = event.index
			elif Rect2(920, 630, 160, 72).has_point(pos):
				touch_jump = true
				active_touch_jump = event.index
			elif Rect2(1092, 630, 170, 72).has_point(pos):
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
				touch_jump = false
				active_touch_jump = -1
			if event.index == active_touch_smash:
				touch_smash = false
				active_touch_smash = -1

func _process(delta):
	game_time += delta
	run_anim_time += delta
	shake_time = max(0.0, shake_time - delta)
	flash_time = max(0.0, flash_time - delta)
	win_timer = max(0.0, win_timer - delta)

	handle_input(delta)
	update_player(delta)
	update_enemies(delta)
	update_props()

	var target_camera = clamp(player_x - 360.0, 0.0, WORLD_W - 1280.0)
	camera_x = lerp(camera_x, target_camera, min(1.0, delta * 6.5))
	queue_redraw()

func handle_input(delta):
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
		active_touch_jump = -1

	if jump_pressed and player_grounded:
		player_vy = -720.0
		player_grounded = false

	var smash_pressed = Input.is_action_just_pressed("smash")
	if touch_smash:
		smash_pressed = true
		touch_smash = false
		active_touch_smash = -1

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

	if player_x >= WORLD_W - 250.0:
		win_timer = 3.0
		score += 5000
		player_x = WORLD_W - 250.0

func update_enemies(delta):
	for i in range(enemy_x.size()):
		if not enemy_alive[i]:
			continue

		var dx = player_x - enemy_x[i]

		if abs(dx) < 560.0:
			var enemy_dir = 1.0
			if dx < 0.0:
				enemy_dir = -1.0
			enemy_x[i] += enemy_dir * 105.0 * delta

		var touching = abs(player_x - enemy_x[i]) < 88.0 and abs((player_y + 60.0) - (FLOOR_Y - 62.0)) < 105.0

		if touching:
			if smash_timer > 0.0:
				enemy_hp[i] -= 1
				enemy_x[i] += player_facing * 105.0
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
		if abs(player_x - prop_x[i]) < 125.0:
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
	draw_background()
	draw_vhs_quarter()
	draw_props()
	draw_enemies()
	draw_player()
	draw_hud()
	draw_mobile_controls()

	if flash_time > 0.0:
		draw_rect(Rect2(0, 0, 1280, 720), Color(1, 1, 1, 0.18))

func draw_background():
	draw_rect(Rect2(0, 0, 1280, 720), Color("#080510"))

	var sx = get_shake_x()
	var sy = get_shake_y()

	# distant skyline
	for i in range(18):
		var bx = fmod(float(i) * 165.0 - camera_x * 0.12, 1500.0) - 120.0
		var bh = 110.0 + float((i * 67) % 230)
		draw_rect(Rect2(bx + sx, 515.0 - bh + sy, 105.0, bh), Color("#171128"))
		if i % 2 == 0:
			draw_line(Vector2(bx + 8.0 + sx, 535.0 - bh + sy), Vector2(bx + 92.0 + sx, 535.0 - bh + sy), Color("#ff2d95"), 3.0)

	draw_rect(Rect2(0, FLOOR_Y, 1280, 110), Color("#08080c"))
	draw_line(Vector2(0, FLOOR_Y), Vector2(1280, FLOOR_Y), Color("#ff2d95"), 3.0)

	for x in range(-100, 1400, 120):
		var xx = float(x) - fmod(camera_x * 0.7, 120.0)
		draw_line(Vector2(xx, FLOOR_Y + 44.0), Vector2(xx + 58.0, FLOOR_Y + 44.0), Color("#8aff2b"), 4.0)

func draw_vhs_quarter():
	var sx = get_shake_x()
	var sy = get_shake_y()

	# landmark storefronts
	draw_world_texture(vhs_store, 420.0, 240.0, 360.0, 462.0, sx, sy)
	draw_world_texture(vhs_store, 3050.0, 250.0, 350.0, 448.0, sx, sy)
	draw_world_texture(vhs_store, 5720.0, 245.0, 360.0, 462.0, sx, sy)

	# large signage / billboards
	draw_world_texture(vhs_sign, 1180.0, 260.0, 330.0, 245.0, sx, sy)
	draw_world_texture(no_refunds, 2080.0, 300.0, 360.0, 145.0, sx, sy)
	draw_world_texture(vhs_billboard, 3890.0, 235.0, 300.0, 560.0, sx, sy)
	draw_world_texture(vhs_sign, 5000.0, 275.0, 310.0, 230.0, sx, sy)

	# street clutter
	draw_world_texture(crt_stack, 1580.0, 455.0, 210.0, 138.0, sx, sy)
	draw_world_texture(dumpster, 2720.0, 465.0, 190.0, 132.0, sx, sy)
	draw_world_texture(crt_stack, 4430.0, 452.0, 210.0, 138.0, sx, sy)
	draw_world_texture(dumpster, 6250.0, 465.0, 190.0, 132.0, sx, sy)

	# decorative VHS piles
	draw_world_texture(tape_pile, 890.0, 548.0, 115.0, 44.0, sx, sy)
	draw_world_texture(tape_pile, 3360.0, 548.0, 115.0, 44.0, sx, sy)
	draw_world_texture(tape_pile, 5350.0, 548.0, 115.0, 44.0, sx, sy)

	# platforms / sidewalks
	draw_world_texture(platform_long, 1850.0, 525.0, 430.0, 98.0, sx, sy)
	draw_world_texture(platform_short, 4820.0, 520.0, 220.0, 132.0, sx, sy)

func draw_world_texture(tex, world_x, screen_y, width, height, sx, sy):
	var px = world_x - camera_x + sx
	if px < -width - 60.0 or px > 1340.0:
		return
	draw_texture_rect(tex, Rect2(px, screen_y + sy, width, height), false)

func draw_props():
	for i in range(prop_x.size()):
		if not prop_alive[i]:
			continue

		var px = prop_x[i] - camera_x + get_shake_x()
		if px < -140.0 or px > 1400.0:
			continue

		if prop_kind[i] == 0:
			draw_texture_rect(toxic_barrel, Rect2(px, FLOOR_Y - 105.0, 82.0, 105.0), false)
		elif prop_kind[i] == 1:
			draw_texture_rect(hazard_barrel, Rect2(px, FLOOR_Y - 102.0, 76.0, 102.0), false)
		elif prop_kind[i] == 2:
			draw_texture_rect(tape_boost, Rect2(px, FLOOR_Y - 90.0, 72.0, 90.0), false)
		else:
			draw_texture_rect(mine_tex, Rect2(px, FLOOR_Y - 68.0, 72.0, 58.0), false)

func draw_enemies():
	for i in range(enemy_x.size()):
		if not enemy_alive[i]:
			continue

		var ex = enemy_x[i] - camera_x + get_shake_x()
		if ex < -180.0 or ex > 1400.0:
			continue

		var tex = enemy_mutant_idle
		if abs(player_x - enemy_x[i]) < 560.0:
			tex = enemy_mutant_run

		draw_texture_rect(tex, Rect2(ex - 58.0, FLOOR_Y - 146.0 + get_shake_y(), 132.0, 146.0), false)

func draw_player():
	var px = player_x - camera_x + get_shake_x()
	var py = player_y + get_shake_y()

	var tex = hc_idle

	if win_timer > 0.0:
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

	draw_texture_rect(tex, Rect2(px - 48.0, py - 12.0, 132.0, 126.0), false)

	if smash_timer > 0.0:
		var hit_x = px + 105.0
		if player_facing < 0.0:
			hit_x = px - 35.0
		draw_circle(Vector2(hit_x, py + 58.0), 34.0, Color(1.0, 0.18, 0.58, 0.30))

func draw_hud():
	draw_rect(Rect2(0, 0, 1280, 104), Color("#050508f2"))
	draw_line(Vector2(0, 103), Vector2(1280, 103), Color("#ff2d95"), 2.0)

	draw_string(ThemeDB.fallback_font, Vector2(28, 48), "TTD: DEATH RUN", HORIZONTAL_ALIGNMENT_LEFT, -1, 34, Color("#f3efe8"))
	draw_string(ThemeDB.fallback_font, Vector2(28, 78), "TBN EXECUTION BROADCAST // STAGE 01", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("#8aff2b"))

	draw_string(ThemeDB.fallback_font, Vector2(420, 35), "VHS QUARTER", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("#ff2d95"))
	draw_string(ThemeDB.fallback_font, Vector2(420, 64), "SCORE " + str(score), HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color("#f3efe8"))

	draw_string(ThemeDB.fallback_font, Vector2(710, 30), "HARDCASE '87 // HEALTH", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("#f3efe8"))
	draw_rect(Rect2(710, 42, 245, 18), Color("#24101a"))
	draw_rect(Rect2(710, 42, 245.0 * float(player_health) / 100.0, 18), Color("#ff2d95"))

	draw_string(ThemeDB.fallback_font, Vector2(980, 50), "LIVES x " + str(player_lives), HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("#8aff2b"))
	draw_string(ThemeDB.fallback_font, Vector2(1138, 30), "TBN LIVE", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("#ff2d95"))
	draw_string(ThemeDB.fallback_font, Vector2(1138, 57), "RATINGS UP", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("#8aff2b"))

	draw_rect(Rect2(18, 116, 455, 44), Color("#08070be8"))
	draw_rect(Rect2(18, 116, 455, 44), Color("#ff2d95"), false, 2.0)
	draw_string(ThemeDB.fallback_font, Vector2(32, 145), "GRIM LEDGER: SURVIVAL REMAINS BULLISH.", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("#f3efe8"))

func draw_mobile_controls():
	var y = 630.0
	draw_control_button(Rect2(18, y, 150, 72), "LEFT", touch_left, "#f3efe8")
	draw_control_button(Rect2(180, y, 150, 72), "RIGHT", touch_right, "#f3efe8")
	draw_control_button(Rect2(920, y, 160, 72), "JUMP", false, "#8aff2b")
	draw_control_button(Rect2(1092, y, 170, 72), "SMASH", false, "#ff2d95")

func draw_control_button(rect, label, pressed, col):
	var bg = Color("#0c0b12dd")
	if pressed:
		bg = Color("#25152bdd")

	draw_rect(rect, bg)
	draw_rect(rect, Color(col), false, 2.0)
	draw_string(ThemeDB.fallback_font, Vector2(rect.position.x + 22.0, rect.position.y + 45.0), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color(col))
