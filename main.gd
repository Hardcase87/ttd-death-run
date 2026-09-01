extends Node2D

const WORLD_W = 7200.0
const FLOOR_Y = 610.0

var player_x = 220.0
var player_y = FLOOR_Y - 92.0
var player_vx = 0.0
var player_vy = 0.0
var player_w = 62.0
var player_h = 92.0
var player_grounded = true
var player_facing = 1.0
var player_health = 100
var player_lives = 3
var smash_timer = 0.0
var hurt_timer = 0.0

var camera_x = 0.0
var score = 0
var stage = 1
var checkpoint = 0.0
var game_time = 0.0

var enemy_x = [1000.0, 1680.0, 2400.0, 3400.0, 4520.0, 5900.0]
var enemy_hp = [2, 2, 3, 3, 4, 4]
var enemy_alive = [true, true, true, true, true, true]

func _ready():
	queue_redraw()

func _process(delta):
	game_time += delta
	handle_input(delta)
	update_player(delta)
	update_enemies(delta)
	var target_camera = clamp(player_x - 360.0, 0.0, WORLD_W - 1280.0)
	camera_x = lerp(camera_x, target_camera, min(1.0, delta * 6.0))
	queue_redraw()

func handle_input(delta):
	var direction = 0.0

	if Input.is_action_pressed("move_left"):
		direction -= 1.0
	if Input.is_action_pressed("move_right"):
		direction += 1.0

	if direction != 0.0:
		player_facing = direction

	player_vx = move_toward(player_vx, direction * 390.0, 1600.0 * delta)

	if Input.is_action_just_pressed("jump") and player_grounded:
		player_vy = -690.0
		player_grounded = false

	if Input.is_action_just_pressed("smash") and smash_timer <= 0.0:
		smash_timer = 0.28

func update_player(delta):
	smash_timer = max(0.0, smash_timer - delta)
	hurt_timer = max(0.0, hurt_timer - delta)

	player_vy += 1850.0 * delta
	player_x += player_vx * delta
	player_y += player_vy * delta

	player_x = clamp(player_x, 60.0, WORLD_W - 80.0)

	if player_y >= FLOOR_Y - player_h:
		player_y = FLOOR_Y - player_h
		player_vy = 0.0
		player_grounded = true

	if player_x > checkpoint + 1500.0:
		checkpoint = player_x

	if player_x >= WORLD_W - 220.0:
		stage_complete()

func update_enemies(delta):
	for i in range(enemy_x.size()):
		if not enemy_alive[i]:
			continue

		var dx = player_x - enemy_x[i]

		if abs(dx) < 520.0:
			var enemy_dir = 1.0
			if dx < 0.0:
				enemy_dir = -1.0
			enemy_x[i] += enemy_dir * 95.0 * delta

		var touching = abs(player_x - enemy_x[i]) < 70.0 and abs((player_y + 46.0) - (FLOOR_Y - 33.0)) < 75.0

		if touching:
			if smash_timer > 0.0:
				enemy_hp[i] -= 1
				enemy_x[i] += player_facing * 70.0
				if enemy_hp[i] <= 0:
					enemy_alive[i] = false
					score += 500
			elif hurt_timer <= 0.0:
				player_health -= 10
				hurt_timer = 0.8
				if player_health <= 0:
					lose_life()

func lose_life():
	player_lives -= 1
	player_health = 100
	player_x = max(220.0, checkpoint - 250.0)
	player_y = FLOOR_Y - player_h

	if player_lives < 0:
		player_lives = 3
		score = 0
		checkpoint = 0.0
		player_x = 220.0
		for i in range(enemy_alive.size()):
			enemy_alive[i] = true
			enemy_hp[i] = 2

func stage_complete():
	score += 5000
	player_x = 220.0
	checkpoint = 0.0
	stage += 1
	if stage > 8:
		stage = 8

func _draw():
	draw_background()
	draw_world()
	draw_player()
	draw_enemies()
	draw_hud()
	draw_mobile_controls()

func draw_background():
	draw_rect(Rect2(0, 0, 1280, 720), Color("#07060b"))

	for i in range(22):
		var bx = fmod(float(i) * 190.0 - camera_x * 0.18, 1500.0) - 120.0
		var bh = 150.0 + float((i * 73) % 220)
		draw_rect(Rect2(bx, 520.0 - bh, 110.0, bh), Color("#171128"))
		draw_line(Vector2(bx + 15.0, 545.0 - bh), Vector2(bx + 95.0, 545.0 - bh), Color("#ff2d95"), 3.0)

	draw_rect(Rect2(0, 515, 1280, 205), Color("#0b0910"))
	draw_line(Vector2(0, FLOOR_Y), Vector2(1280, FLOOR_Y), Color("#ff2d95"), 3.0)

	for x in range(-100, 1400, 120):
		var xx = float(x) - fmod(camera_x * 0.7, 120.0)
		draw_line(Vector2(xx, FLOOR_Y + 45.0), Vector2(xx + 45.0, FLOOR_Y + 45.0), Color("#8aff2b"), 4.0)

func draw_world():
	draw_sign(520.0, "VHS PALACE")
	draw_sign(1260.0, "REWIND OR DIE")
	draw_sign(2140.0, "TDI // OBEY")
	draw_sign(3220.0, "TBN LIVE")
	draw_sign(4380.0, "SKULL JUICE")
	draw_sign(5660.0, "NO REFUNDS")
	draw_sign(6760.0, "EXIT // MAYBE")

func draw_sign(world_x, label):
	var sx = world_x - camera_x
	if sx > -300.0 and sx < 1500.0:
		draw_rect(Rect2(sx, 270, 210, 68), Color("#170c1c"))
		draw_rect(Rect2(sx, 270, 210, 68), Color("#ff2d95"), false, 3.0)
		draw_string(ThemeDB.fallback_font, Vector2(sx + 14.0, 312.0), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color("#f5f0e8"))

func draw_player():
	var px = player_x - camera_x
	var body_color = Color("#222126")

	if hurt_timer > 0.0 and int(game_time * 14.0) % 2 == 1:
		body_color = Color("#ff315e")

	draw_rect(Rect2(px, player_y + 18.0, player_w, player_h - 18.0), body_color)
	draw_circle(Vector2(px + 31.0, player_y + 17.0), 20.0, Color("#2b2529"))
	draw_rect(Rect2(px + 10.0, player_y + 12.0, 42.0, 8.0), Color("#ff2d95"))
	draw_rect(Rect2(px + 8.0, player_y + 42.0, 46.0, 15.0), Color("#111114"))
	draw_string(ThemeDB.fallback_font, Vector2(px + 10.0, player_y + 54.0), "87", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("#f3efe8"))

	if smash_timer > 0.0:
		var hit_x = px + 95.0
		if player_facing < 0.0:
			hit_x = px - 35.0
		draw_circle(Vector2(hit_x, player_y + 56.0), 28.0, Color("#ff2d95"))
		draw_circle(Vector2(hit_x, player_y + 56.0), 16.0, Color("#ffe53b"))

func draw_enemies():
	for i in range(enemy_x.size()):
		if not enemy_alive[i]:
			continue

		var ex = enemy_x[i] - camera_x

		if ex < -100.0 or ex > 1400.0:
			continue

		var ey = FLOOR_Y - 66.0
		draw_rect(Rect2(ex, ey, 52.0, 66.0), Color("#283315"))
		draw_rect(Rect2(ex + 8.0, ey + 12.0, 36.0, 12.0), Color("#8aff2b"))
		draw_circle(Vector2(ex + 26.0, ey + 8.0), 14.0, Color("#574324"))
		draw_string(ThemeDB.fallback_font, Vector2(ex + 5.0, ey + 58.0), "TDI", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("#ff2d95"))

func draw_hud():
	draw_rect(Rect2(0, 0, 1280, 82), Color("#050508ee"))
	draw_line(Vector2(0, 82), Vector2(1280, 82), Color("#ff2d95"), 2.0)

	draw_string(ThemeDB.fallback_font, Vector2(28, 48), "TTD: DEATH RUN", HORIZONTAL_ALIGNMENT_LEFT, -1, 34, Color("#f3efe8"))
	draw_string(ThemeDB.fallback_font, Vector2(365, 31), "STAGE " + str(stage) + " // VHS QUARTER", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("#8aff2b"))
	draw_string(ThemeDB.fallback_font, Vector2(365, 57), "SCORE " + str(score), HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color("#f3efe8"))

	draw_string(ThemeDB.fallback_font, Vector2(710, 31), "HEALTH", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("#f3efe8"))
	draw_rect(Rect2(710, 42, 220, 18), Color("#22111b"))
	draw_rect(Rect2(710, 42, 220.0 * float(player_health) / 100.0, 18), Color("#ff2d95"))

	draw_string(ThemeDB.fallback_font, Vector2(960, 48), "LIVES x " + str(player_lives), HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color("#8aff2b"))
	draw_string(ThemeDB.fallback_font, Vector2(1130, 32), "TBN LIVE", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("#ff2d95"))
	draw_string(ThemeDB.fallback_font, Vector2(1130, 57), "RATINGS UP", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("#8aff2b"))

	draw_rect(Rect2(18, 92, 390, 48), Color("#060609dd"))
	draw_rect(Rect2(18, 92, 390, 48), Color("#ff2d95"), false, 2.0)
	draw_string(ThemeDB.fallback_font, Vector2(32, 123), "TBN // SURVIVE FOR SHAREHOLDER VALUE", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("#f3efe8"))

func draw_mobile_controls():
	var y = 640.0

	draw_rect(Rect2(18, y, 96, 60), Color("#0d0c12cc"))
	draw_rect(Rect2(124, y, 96, 60), Color("#0d0c12cc"))
	draw_rect(Rect2(930, y, 150, 60), Color("#0d0c12cc"))
	draw_rect(Rect2(1092, y, 170, 60), Color("#0d0c12cc"))

	draw_string(ThemeDB.fallback_font, Vector2(48, y + 39.0), "LEFT", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("#f3efe8"))
	draw_string(ThemeDB.fallback_font, Vector2(147, y + 39.0), "RIGHT", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("#f3efe8"))
	draw_string(ThemeDB.fallback_font, Vector2(972, y + 38.0), "JUMP", HORIZONTAL_ALIGNMENT_LEFT, -1, 21, Color("#8aff2b"))
	draw_string(ThemeDB.fallback_font, Vector2(1124, y + 38.0), "SMASH", HORIZONTAL_ALIGNMENT_LEFT, -1, 21, Color("#ff2d95"))
