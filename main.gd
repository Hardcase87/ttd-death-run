extends Node2D

const WORLD_W = 7200.0
const FLOOR_Y = 610.0

var hardcase_tex = preload("res://assets/hardcase.png")
var enemy_tex = preload("res://assets/tdi-enemy.png")
var barrel_tex = preload("res://assets/barrel.png")
var crt_tex = preload("res://assets/crt.png")
var bg_far_tex = preload("res://assets/bg-far.png")
var bg_mid_tex = preload("res://assets/bg-mid.png")
var bg_near_tex = preload("res://assets/bg-near.png")

var player_x = 220.0
var player_y = FLOOR_Y - 108.0
var player_vx = 0.0
var player_vy = 0.0
var player_grounded = true
var player_facing = 1.0
var player_health = 100
var player_lives = 3
var smash_timer = 0.0
var hurt_timer = 0.0

var camera_x = 0.0
var shake_time = 0.0
var shake_power = 0.0
var flash_time = 0.0
var score = 0
var stage = 1
var checkpoint = 0.0
var game_time = 0.0

# Touch holds
var touch_left = false
var touch_right = false
var touch_jump = false
var touch_smash = false
var active_touch_left = -1
var active_touch_right = -1
var active_touch_jump = -1
var active_touch_smash = -1

var enemy_x = [1050.0, 1750.0, 2500.0, 3550.0, 4700.0, 5900.0]
var enemy_hp = [2, 2, 3, 3, 4, 4]
var enemy_alive = [true, true, true, true, true, true]

var prop_x = [760.0, 1380.0, 2050.0, 2920.0, 3880.0, 5100.0, 6480.0]
var prop_kind = [0, 1, 0, 1, 1, 0, 1] # 0 CRT / 1 barrel
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
	shake_time = max(0.0, shake_time - delta)
	flash_time = max(0.0, flash_time - delta)

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

	if player_y >= FLOOR_Y - 108.0:
		player_y = FLOOR_Y - 108.0
		player_vy = 0.0
		player_grounded = true

	if player_x > checkpoint + 1500.0:
		checkpoint = player_x

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

		var touching = abs(player_x - enemy_x[i]) < 72.0 and abs((player_y + 54.0) - (FLOOR_Y - 54.0)) < 90.0

		if touching:
			if smash_timer > 0.0:
				enemy_hp[i] -= 1
				enemy_x[i] += player_facing * 95.0
				kick_camera(0.14, 8.0)
				flash_time = 0.06
				if enemy_hp[i] <= 0:
					enemy_alive[i] = false
					score += 500
					kick_camera(0.20, 13.0)
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
		var hit_dist = abs(player_x - prop_x[i])
		if hit_dist < 115.0:
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
	player_y = FLOOR_Y - 108.0
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
	draw_stage_world()
	draw_props()
	draw_enemies()
	draw_player()
	draw_hud()
	draw_mobile_controls()
	if flash_time > 0.0:
		draw_rect(Rect2(0,0,1280,720), Color(1,1,1,0.18))

func draw_background():
	draw_rect(Rect2(0,0,1280,720), Color("#07060b"))

	var sx = get_shake_x()
	var sy = get_shake_y()

	var far_off = -fmod(camera_x * 0.10, 1600.0)
	draw_texture(bg_far_tex, Vector2(far_off + sx, 70 + sy))
	draw_texture(bg_far_tex, Vector2(far_off + 1600.0 + sx, 70 + sy))

	var mid_off = -fmod(camera_x * 0.24, 1600.0)
	draw_texture(bg_mid_tex, Vector2(mid_off + sx, 160 + sy))
	draw_texture(bg_mid_tex, Vector2(mid_off + 1600.0 + sx, 160 + sy))

	var near_off = -fmod(camera_x * 0.46, 1600.0)
	draw_texture(bg_near_tex, Vector2(near_off + sx, 250 + sy))
	draw_texture(bg_near_tex, Vector2(near_off + 1600.0 + sx, 250 + sy))

	# ground
	draw_rect(Rect2(0, FLOOR_Y, 1280, 110), Color("#09090d"))
	draw_line(Vector2(0,FLOOR_Y), Vector2(1280,FLOOR_Y), Color("#ff2d95"), 3.0)
	for x in range(-100, 1400, 120):
		var xx = float(x) - fmod(camera_x * 0.7, 120.0)
		draw_line(Vector2(xx,FLOOR_Y+44), Vector2(xx+58,FLOOR_Y+44), Color("#8aff2b"), 4.0)

func draw_stage_world():
	draw_sign(560.0, "VHS PALACE", "#ff2d95")
	draw_sign(1450.0, "REWIND OR DIE", "#8aff2b")
	draw_sign(2380.0, "TDI // TRAIN. SHRED. OBEY.", "#ff2d95")
	draw_sign(3370.0, "TBN LIVE", "#39d7ff")
	draw_sign(4520.0, "SKULL JUICE", "#8aff2b")
	draw_sign(5850.0, "NO REFUNDS", "#ff2d95")
	draw_sign(6820.0, "STAGE EXIT // MAYBE", "#f3efe8")

func draw_sign(world_x, label, col):
	var sx = world_x - camera_x + get_shake_x()
	if sx > -320.0 and sx < 1480.0:
		draw_rect(Rect2(sx,250,300,78), Color("#120b17dd"))
		draw_rect(Rect2(sx,250,300,78), Color(col), false, 3.0)
		draw_string(ThemeDB.fallback_font, Vector2(sx+18,298), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color("#f3efe8"))

func draw_props():
	for i in range(prop_x.size()):
		if not prop_alive[i]:
			continue
		var px = prop_x[i] - camera_x + get_shake_x()
		if px < -120.0 or px > 1400.0:
			continue
		if prop_kind[i] == 0:
			draw_texture_rect(crt_tex, Rect2(px, FLOOR_Y-82, 82,82), false)
		else:
			draw_texture_rect(barrel_tex, Rect2(px, FLOOR_Y-82,82,82), false)

func draw_enemies():
	for i in range(enemy_x.size()):
		if not enemy_alive[i]:
			continue
		var ex = enemy_x[i] - camera_x + get_shake_x()
		if ex < -150.0 or ex > 1400.0:
			continue
		draw_texture_rect(enemy_tex, Rect2(ex-34, FLOOR_Y-112 + get_shake_y(), 112,112), false)

func draw_player():
	var px = player_x - camera_x + get_shake_x()
	var py = player_y + get_shake_y()

	if hurt_timer > 0.0 and int(game_time*14.0)%2 == 1:
		modulate = Color(1,0.35,0.45,1)
	else:
		modulate = Color.WHITE

	draw_texture_rect(hardcase_tex, Rect2(px-25,py-18,128,128), false)
	modulate = Color.WHITE

	if smash_timer > 0.0:
		var hit_x = px + 105.0
		if player_facing < 0.0:
			hit_x = px - 35.0
		draw_circle(Vector2(hit_x,py+58), 34.0, Color(1.0,0.18,0.58,0.55))
		draw_circle(Vector2(hit_x,py+58), 18.0, Color(1.0,0.90,0.23,0.82))

func draw_hud():
	draw_rect(Rect2(0,0,1280,104), Color("#050508f2"))
	draw_line(Vector2(0,103),Vector2(1280,103),Color("#ff2d95"),2.0)

	draw_string(ThemeDB.fallback_font, Vector2(28,48), "TTD: DEATH RUN", HORIZONTAL_ALIGNMENT_LEFT, -1, 34, Color("#f3efe8"))
	draw_string(ThemeDB.fallback_font, Vector2(28,78), "TBN EXECUTION BROADCAST // STAGE 01", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("#8aff2b"))

	draw_string(ThemeDB.fallback_font, Vector2(420,35), "VHS QUARTER", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("#ff2d95"))
	draw_string(ThemeDB.fallback_font, Vector2(420,64), "SCORE " + str(score), HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color("#f3efe8"))

	draw_string(ThemeDB.fallback_font, Vector2(710,30), "HARDCASE '87 // HEALTH", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("#f3efe8"))
	draw_rect(Rect2(710,42,245,18),Color("#24101a"))
	draw_rect(Rect2(710,42,245.0*float(player_health)/100.0,18),Color("#ff2d95"))

	draw_string(ThemeDB.fallback_font, Vector2(980,50), "LIVES x " + str(player_lives), HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("#8aff2b"))
	draw_string(ThemeDB.fallback_font, Vector2(1138,30), "TBN LIVE", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("#ff2d95"))
	draw_string(ThemeDB.fallback_font, Vector2(1138,57), "RATINGS UP", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("#8aff2b"))

	draw_rect(Rect2(18,116,445,44),Color("#08070be8"))
	draw_rect(Rect2(18,116,445,44),Color("#ff2d95"),false,2.0)
	draw_string(ThemeDB.fallback_font,Vector2(32,145),"GRIM LEDGER: SURVIVAL REMAINS BULLISH.",HORIZONTAL_ALIGNMENT_LEFT,-1,17,Color("#f3efe8"))

func draw_mobile_controls():
	var y = 630.0
	draw_control_button(Rect2(18,y,150,72),"LEFT",touch_left,"#f3efe8")
	draw_control_button(Rect2(180,y,150,72),"RIGHT",touch_right,"#f3efe8")
	draw_control_button(Rect2(920,y,160,72),"JUMP",false,"#8aff2b")
	draw_control_button(Rect2(1092,y,170,72),"SMASH",false,"#ff2d95")

func draw_control_button(rect,label,pressed,col):
	var bg = Color("#0c0b12dd")
	if pressed:
		bg = Color("#25152bdd")
	draw_rect(rect,bg)
	draw_rect(rect,Color(col),false,2.0)
	draw_string(ThemeDB.fallback_font,Vector2(rect.position.x+22,rect.position.y+45),label,HORIZONTAL_ALIGNMENT_LEFT,-1,22,Color(col))
