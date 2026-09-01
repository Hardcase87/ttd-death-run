extends Node2D

const WORLD_W := 7200.0
const FLOOR_Y := 610.0

var player := {
	"x": 220.0,
	"y": FLOOR_Y - 92.0,
	"vx": 0.0,
	"vy": 0.0,
	"w": 62.0,
	"h": 92.0,
	"grounded": true,
	"facing": 1.0,
	"health": 100,
	"lives": 3,
	"smash_timer": 0.0,
	"hurt_timer": 0.0
}

var camera_x := 0.0
var score := 0
var stage := 1
var checkpoint := 0.0
var game_time := 0.0

var enemies := [
	{"x": 1000.0, "y": FLOOR_Y-66.0, "hp": 2, "alive": true, "dir": -1.0},
	{"x": 1680.0, "y": FLOOR_Y-66.0, "hp": 2, "alive": true, "dir": -1.0},
	{"x": 2400.0, "y": FLOOR_Y-66.0, "hp": 3, "alive": true, "dir": 1.0},
	{"x": 3400.0, "y": FLOOR_Y-66.0, "hp": 3, "alive": true, "dir": -1.0},
	{"x": 4520.0, "y": FLOOR_Y-66.0, "hp": 4, "alive": true, "dir": -1.0},
	{"x": 5900.0, "y": FLOOR_Y-66.0, "hp": 4, "alive": true, "dir": -1.0}
]

var props := [
	{"x": 760.0, "kind":"vhs"},
	{"x": 1450.0, "kind":"barrel"},
	{"x": 2050.0, "kind":"crt"},
	{"x": 3000.0, "kind":"barrel"},
	{"x": 4100.0, "kind":"vhs"},
	{"x": 5200.0, "kind":"crt"},
	{"x": 6500.0, "kind":"barrel"}
]

func _ready():
	queue_redraw()

func _physics_process(delta):
	game_time += delta
	handle_input(delta)
	update_player(delta)
	update_enemies(delta)
	camera_x = lerp(camera_x, clamp(player.x - 360.0, 0.0, WORLD_W - 1280.0), min(1.0, delta * 6.0))
	queue_redraw()

func handle_input(delta):
	var dir := 0.0
	if Input.is_action_pressed("move_left"):
		dir -= 1.0
	if Input.is_action_pressed("move_right"):
		dir += 1.0

	if dir != 0.0:
		player.facing = dir
	player.vx = move_toward(player.vx, dir * 390.0, 1600.0 * delta)

	if Input.is_action_just_pressed("jump") and player.grounded:
		player.vy = -690.0
		player.grounded = false

	if Input.is_action_just_pressed("smash") and player.smash_timer <= 0.0:
		player.smash_timer = 0.28

func update_player(delta):
	player.smash_timer = max(0.0, player.smash_timer - delta)
	player.hurt_timer = max(0.0, player.hurt_timer - delta)

	player.vy += 1850.0 * delta
	player.x += player.vx * delta
	player.y += player.vy * delta

	player.x = clamp(player.x, 60.0, WORLD_W - 80.0)

	if player.y >= FLOOR_Y - player.h:
		player.y = FLOOR_Y - player.h
		player.vy = 0.0
		player.grounded = true

	if player.x > checkpoint + 1500.0:
		checkpoint = player.x

	if player.x >= WORLD_W - 220:
		stage_complete()

func update_enemies(delta):
	for e in enemies:
		if not e.alive:
			continue

		var dx: float = player.x - e.x
		if abs(dx) < 520:
			e.dir = sign(dx)
			e.x += e.dir * 95.0 * delta

		var touching := abs(player.x - e.x) < 70 and abs((player.y+player.h*0.5) - (e.y+33)) < 75
		if touching:
			if player.smash_timer > 0.0:
				e.hp -= 1
				e.x += player.facing * 70.0
				if e.hp <= 0:
					e.alive = false
					score += 500
			elif player.hurt_timer <= 0.0:
				player.health -= 10
				player.hurt_timer = 0.8
				player.vx = -e.dir * 260
				if player.health <= 0:
					lose_life()

func lose_life():
	player.lives -= 1
	player.health = 100
	player.x = max(220.0, checkpoint - 250.0)
	player.y = FLOOR_Y - player.h
	if player.lives < 0:
		player.lives = 3
		score = 0
		checkpoint = 0
		player.x = 220.0
		for e in enemies:
			e.alive = true
			e.hp = 2

func stage_complete():
	score += 5000
	player.x = 220.0
	checkpoint = 0.0
	stage = min(stage + 1, 8)

func _draw():
	draw_background()
	draw_world()
	draw_player()
	draw_enemies()
	draw_hud()
	draw_mobile_controls()

func draw_background():
	draw_rect(Rect2(0,0,1280,720), Color("#07060b"))
	# neon skyline parallax
	for i in range(22):
		var bx := fmod(i * 190.0 - camera_x * 0.18, 1500.0) - 120.0
		var bh := 150.0 + float((i*73)%220)
		draw_rect(Rect2(bx, 520-bh, 110, bh), Color("#171128"))
		draw_line(Vector2(bx+15,520-bh+25), Vector2(bx+95,520-bh+25), Color("#ff2d95"), 3)
		for y in range(int(520-bh+50), 500, 34):
			draw_rect(Rect2(bx+18,y,8,10), Color("#8aff2b"))
			draw_rect(Rect2(bx+62,y,8,10), Color("#39d7ff"))

	# skyline glow and road
	draw_rect(Rect2(0,515,1280,205), Color("#0b0910"))
	draw_line(Vector2(0,FLOOR_Y), Vector2(1280,FLOOR_Y), Color("#ff2d95"), 3)
	for x in range(-100,1400,120):
		var xx := float(x) - fmod(camera_x*0.7,120.0)
		draw_line(Vector2(xx,FLOOR_Y+45), Vector2(xx+45,FLOOR_Y+45), Color("#8aff2b"), 4)

func draw_world():
	# level signage
	var signs = [
		[520.0, "VHS PALACE"],
		[1260.0, "REWIND OR DIE"],
		[2140.0, "TDI // OBEY"],
		[3220.0, "TBN LIVE"],
		[4380.0, "SKULL JUICE"],
		[5660.0, "NO REFUNDS"],
		[6760.0, "EXIT // MAYBE"]
	]
	for s in signs:
		var sx: float = float(s[0]) - camera_x
		if sx > -300 and sx < 1500:
			draw_rect(Rect2(sx, 270, 210, 68), Color("#170c1c"))
			draw_rect(Rect2(sx, 270, 210, 68), Color("#ff2d95"), false, 3)
			draw_string(ThemeDB.fallback_font, Vector2(sx+14,312), str(s[1]), HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color("#f5f0e8"))

	for p in props:
		var px: float = p.x - camera_x
		if px < -100 or px > 1400:
			continue
		match p.kind:
			"barrel":
				draw_rect(Rect2(px,FLOOR_Y-58,44,58), Color("#32323b"))
				draw_rect(Rect2(px,FLOOR_Y-58,44,58), Color("#8aff2b"), false, 3)
				draw_string(ThemeDB.fallback_font, Vector2(px+8,FLOOR_Y-22), "87", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("#ff2d95"))
			"crt":
				draw_rect(Rect2(px,FLOOR_Y-48,66,48), Color("#15151b"))
				draw_rect(Rect2(px+7,FLOOR_Y-41,52,28), Color("#39d7ff"))
			_:
				draw_rect(Rect2(px,FLOOR_Y-24,58,24), Color("#ff2d95"))

func draw_player():
	var px := player.x - camera_x
	var py := player.y
	var body_col := Color("#222126") if player.hurt_timer <= 0.0 or int(game_time*14)%2==0 else Color("#ff315e")
	# Hardcase silhouette
	draw_rect(Rect2(px,py+18,player.w,player.h-18), body_col)
	draw_circle(Vector2(px+31,py+17), 20, Color("#2b2529"))
	draw_rect(Rect2(px+10,py+12,42,8), Color("#ff2d95"))
	draw_rect(Rect2(px+8,py+42,46,15), Color("#111114"))
	draw_string(ThemeDB.fallback_font, Vector2(px+10,py+54), "87", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("#f3efe8"))

	# weapon / smash
	var hand_x := px + (player.w if player.facing > 0 else -22)
	draw_rect(Rect2(hand_x,py+47,28*player.facing,12), Color("#77737d"))
	if player.smash_timer > 0.0:
		var cx := px + (95 if player.facing > 0 else -35)
		draw_circle(Vector2(cx,py+56), 28, Color("#ff2d95"))
		draw_circle(Vector2(cx,py+56), 16, Color("#ffe53b"))

func draw_enemies():
	for e in enemies:
		if not e.alive:
			continue
		var ex: float = e.x - camera_x
		if ex < -100 or ex > 1400:
			continue
		draw_rect(Rect2(ex,e.y,52,66), Color("#283315"))
		draw_rect(Rect2(ex+8,e.y+12,36,12), Color("#8aff2b"))
		draw_circle(Vector2(ex+26,e.y+8), 14, Color("#574324"))
		draw_string(ThemeDB.fallback_font, Vector2(ex+5,e.y+58), "TDI", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("#ff2d95"))

func draw_hud():
	draw_rect(Rect2(0,0,1280,82), Color("#050508ee"))
	draw_line(Vector2(0,82), Vector2(1280,82), Color("#ff2d95"), 2)

	draw_string(ThemeDB.fallback_font, Vector2(28,48), "TTD: DEATH RUN", HORIZONTAL_ALIGNMENT_LEFT, -1, 34, Color("#f3efe8"))
	draw_string(ThemeDB.fallback_font, Vector2(365,31), "STAGE %d // VHS QUARTER" % stage, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("#8aff2b"))
	draw_string(ThemeDB.fallback_font, Vector2(365,57), "SCORE %08d" % score, HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color("#f3efe8"))

	draw_string(ThemeDB.fallback_font, Vector2(710,31), "HEALTH", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("#f3efe8"))
	draw_rect(Rect2(710,42,220,18), Color("#22111b"))
	draw_rect(Rect2(710,42,220.0 * player.health/100.0,18), Color("#ff2d95"))

	draw_string(ThemeDB.fallback_font, Vector2(960,48), "LIVES x %d" % player.lives, HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color("#8aff2b"))
	draw_string(ThemeDB.fallback_font, Vector2(1130,32), "TBN LIVE", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("#ff2d95"))
	draw_string(ThemeDB.fallback_font, Vector2(1130,57), "RATINGS ↑", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("#8aff2b"))

	# evil TV lower-third
	draw_rect(Rect2(18,92,390,48), Color("#060609dd"))
	draw_rect(Rect2(18,92,390,48), Color("#ff2d95"), false, 2)
	draw_string(ThemeDB.fallback_font, Vector2(32,123), "TBN // SURVIVE FOR SHAREHOLDER VALUE", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("#f3efe8"))

func draw_mobile_controls():
	# iPad/Xogot-friendly touch targets (visual only in slice 01; touch handling next patch)
	var y := 640.0
	draw_rect(Rect2(18,y,96,60), Color("#0d0c12cc"))
	draw_rect(Rect2(124,y,96,60), Color("#0d0c12cc"))
	draw_rect(Rect2(930,y,150,60), Color("#0d0c12cc"))
	draw_rect(Rect2(1092,y,170,60), Color("#0d0c12cc"))
	draw_string(ThemeDB.fallback_font, Vector2(50,y+39), "◀", HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color("#f3efe8"))
	draw_string(ThemeDB.fallback_font, Vector2(157,y+39), "▶", HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color("#f3efe8"))
	draw_string(ThemeDB.fallback_font, Vector2(972,y+38), "JUMP", HORIZONTAL_ALIGNMENT_LEFT, -1, 21, Color("#8aff2b"))
	draw_string(ThemeDB.fallback_font, Vector2(1124,y+38), "SMASH", HORIZONTAL_ALIGNMENT_LEFT, -1, 21, Color("#ff2d95"))
