extends Node2D

#Global Variables
@onready var global = get_node("/root/Global")
const newPlayerConstructor = preload("res://player_boat.tscn")
const newSubConstructor = preload("res://enemy_submarine.tscn")
const newPlaneConstructor = preload("res://enemy_airplane.tscn")

#The world is laid out relative to the current screen size. The waterline moves
#from level to level, everything else is measured against it.
const SEABED_H   = 100.0
const SKY_BAND   = 150.0
const SUB_MARGIN = 60.0
const AIR_MARGIN = 70.0
const SKY_MARGIN = 60.0

#One entry per level :
#  water   = waterline, as a fraction of the screen height
#  air     = aircraft raid instead of a submarine hunt
#  enemies = [ horizontal position (0..1) , depth/altitude (0..1) , speed px/sec , seconds between shots ]
const LEVELS = [
	{"water":0.23,"air":false,"enemies":[ [0.10,0.55, 45,4.5] ]},
	{"water":0.23,"air":false,"enemies":[ [0.10,0.25, 40,5.0], [0.75,0.70, 70,4.0] ]},
	{"water":0.30,"air":false,"enemies":[ [0.05,0.20, 55,4.5], [0.60,0.50,-45,4.0], [0.30,0.85, 80,3.5] ]},
	{"water":0.62,"air":true, "enemies":[ [0.10,0.40,120,4.0], [0.80,0.70,-140,3.5] ]},
	{"water":0.18,"air":false,"enemies":[ [0.15,0.30, 70,3.5], [0.85,0.60,-60,3.5], [0.45,0.90,100,3.0] ]},
	{"water":0.35,"air":false,"enemies":[ [0.10,0.15, 90,3.0], [0.50,0.45,-80,3.0], [0.90,0.75, 70,2.5], [0.30,0.95,110,3.0] ]},
	{"water":0.66,"air":true, "enemies":[ [0.05,0.25,160,3.0], [0.50,0.55,-150,3.0], [0.90,0.80,170,2.5] ]},
	{"water":0.25,"air":false,"enemies":[ [0.20,0.35,-110,2.5], [0.70,0.35,110,2.5], [0.20,0.80,90,2.5], [0.70,0.80,-90,2.5] ]},
	{"water":0.30,"air":false,"enemies":[ [0.05,0.20,130,2.2], [0.95,0.40,-130,2.2], [0.05,0.60,120,2.2], [0.95,0.85,-120,2.2] ]},
	{"water":0.60,"air":true, "enemies":[ [0.10,0.20,180,2.5], [0.40,0.50,-170,2.5], [0.70,0.35,190,2.2], [0.95,0.75,-160,2.5] ]},
	{"water":0.20,"air":false,"enemies":[ [0.10,0.25,140,2.0], [0.40,0.45,-120,2.0], [0.70,0.65,150,1.8], [0.25,0.85,-130,1.8], [0.90,0.95,110,2.0] ]},
]

var waterFrac = 0.23
var player = null
var busy   = false
var gameOver = false

#-------------------------------------------------------------------------
# LEVELS
#-------------------------------------------------------------------------
func levelData(newLevel):
	if (newLevel < LEVELS.size()):
		return LEVELS[newLevel]
	#Past the handmade levels the game keeps going, getting harder every round.
	#The generator is seeded with the level number, so level 57 is always the
	#same level 57, in the same order, on every machine and every playthrough.
	var extra = newLevel - LEVELS.size() + 1
	var rng = RandomNumberGenerator.new()
	rng.seed = newLevel
	var air  = (newLevel%3==2)
	var data = []
	for i in min(4+extra,8):
		var speed = rng.randf_range(90,min(90+20*extra,240))
		if air:
			speed *= 1.4
		if (rng.randi()%2==0):
			speed = -speed
		data.append([rng.randf_range(0.05,0.95), rng.randf_range(0.1,0.95),
					 speed, max(1.2,2.0-0.05*extra)])
	var water = 0.62 if air else rng.randf_range(0.18,0.35)
	return {"water":water,"air":air,"enemies":data}

func createPlayer():
	player = newPlayerConstructor.instantiate()
	player.position = Vector2(get_viewport_rect().size.x*0.5, global.waterY-2)
	add_child(player)

func createEnemy(x,depth,speed,timing):
	var newEnemy = newPlaneConstructor.instantiate() if global.airMode else newSubConstructor.instantiate()
	newEnemy.position = Vector2(x,enemyY(depth))
	newEnemy.depth    = depth
	newEnemy.speed    = speed
	newEnemy.timing   = timing
	add_child(newEnemy)

func clearLevel():
	for child in get_children():
		if (child is EnemySubmarine) or (child is EnemyAirplane) or (child is Barrel) or (child is EnemyBomb):
			child.queue_free()
	global.enemies = 0

#the animated switch between a submarine hunt and an aircraft raid
func changeSeaLevel(data):
	var rising = (data["water"] < waterFrac)
	if (abs(data["water"]-waterFrac)<0.01) and (data["air"]==global.airMode):
		return
	$sonarSound.play()
	if data["air"]:
		$HUD.showBanner("AIRCRAFT INBOUND\nTHE SEA IS DRAINING", 0.0)
	elif rising:
		$HUD.showBanner("THE SEA IS RISING\nSUBMARINES RETURNING", 0.0)
	else:
		$HUD.showBanner("THE SEA IS FALLING", 0.0)
	global.airMode = data["air"]
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_method(setSeaLevel, waterFrac, data["water"], 2.0)
	await tween.finished

func setSeaLevel(frac):
	waterFrac = frac
	layoutWorld()

func startLevel(newLevel):
	busy = true
	global.level = newLevel
	clearLevel()
	if not is_instance_valid(player):
		createPlayer()
	global.ammo = global.START_AMMO
	var data = levelData(newLevel)
	await changeSeaLevel(data)
	for enemy in data["enemies"]:
		createEnemy(enemy[0]*get_viewport_rect().size.x, enemy[1], enemy[2], enemy[3])
	$HUD.showBanner("LEVEL %d" % (newLevel+1), 1.5)
	busy = false

func levelCleared():
	$winSound.play()
	$HUD.showBanner("LEVEL %d CLEARED" % (global.level+1), 2.0)
	await get_tree().create_timer(2.0).timeout
	startLevel(global.level+1)

func playerDied():
	global.lives -= 1
	if (global.lives<=0):
		clearLevel()
		gameOver = true
		$HUD.showBanner("GAME OVER\nSCORE %d\n\nTAP TO PLAY AGAIN" % global.score, 0.0)
		return
	$HUD.showBanner("%d BOATS LEFT" % global.lives, 1.5)
	await get_tree().create_timer(1.5).timeout
	startLevel(global.level)

#-------------------------------------------------------------------------
# SCREEN LAYOUT - called again every time the screen or the sea level changes
#-------------------------------------------------------------------------
func enemyY(depth):
	#aircraft fly between the top of the screen and the waterline,
	#submarines sit between the waterline and the sea bed
	var vp = get_viewport_rect().size
	if global.airMode:
		return SKY_MARGIN + depth*(global.waterY-AIR_MARGIN-SKY_MARGIN)
	var top = global.waterY + SUB_MARGIN
	return top + depth*((vp.y-SEABED_H-SUB_MARGIN)-top)

func stretchSprite(sprite,y,height,tile):
	#tile the 512x64 background textures across the full width of the screen
	var vp = get_viewport_rect().size
	var s  = height/tile.y
	sprite.centered       = false
	sprite.region_enabled = true
	sprite.texture_repeat = CanvasItem.TEXTURE_REPEAT_MIRROR
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.region_rect    = Rect2(0,0,vp.x/s,tile.y)
	sprite.scale          = Vector2(s,s)
	sprite.position       = Vector2(0,y)

func stretchBorder(border,x):
	var vp = get_viewport_rect().size
	var shape = border.get_node("CollisionShape2D")
	border.position = Vector2(x,0)
	#the two borders are instances of the same scene, so give each its own shape
	shape.shape = RectangleShape2D.new()
	shape.shape.size = Vector2(20,vp.y*2)
	shape.position   = Vector2(-10 if x<=0 else 10, vp.y*0.5)

func layoutWorld():
	var vp = get_viewport_rect().size
	global.waterY = waterFrac*vp.y

	$SkyBack.position = Vector2.ZERO
	$SkyBack.size     = vp
	stretchSprite($sky/Sky,global.waterY-SKY_BAND,SKY_BAND,Vector2(512,64))
	stretchSprite($rockBottom/RockBottom,vp.y-SEABED_H,SEABED_H,Vector2(512,64))

	$sky.position = Vector2.ZERO
	$sky.scale    = Vector2.ONE
	$rockBottom.position = Vector2.ZERO
	$rockBottom.scale    = Vector2.ONE

	$Ocean.position = Vector2(0,global.waterY)
	$Ocean.scale    = Vector2.ONE
	$Ocean/ColorRect.size = Vector2(vp.x,vp.y-global.waterY)

	$surface.position = Vector2(0,global.waterY)
	$surface/ColorRect.size = Vector2(vp.x,4)
	$surface/CollisionShape2D.shape.size = Vector2(vp.x,6)
	$surface/CollisionShape2D.position   = Vector2(vp.x*0.5,3)

	$bottom.position = Vector2(0,vp.y-12)
	$bottom/ColorRect.size = Vector2(vp.x,12)
	$bottom/CollisionShape2D.shape.size = Vector2(vp.x,12)
	$bottom/CollisionShape2D.position   = Vector2(vp.x*0.5,6)

	stretchBorder($BorderLeft,0)
	stretchBorder($BorderRight,vp.x)

	#carry the enemies along with the waterline (the boat rides it by itself)
	for child in get_children():
		if (child is EnemySubmarine) or (child is EnemyAirplane):
			child.position.y = enemyY(child.depth)

#-------------------------------------------------------------------------
func _ready():
	global.resetGame()
	global.airMode = LEVELS[0]["air"]
	waterFrac      = LEVELS[0]["water"]
	get_viewport().size_changed.connect(layoutWorld)
	layoutWorld()
	startLevel(0)

func _process(delta):
	if busy:
		return
	if not is_instance_valid(player):
		busy = true
		playerDied()
	elif (global.enemies<=0):
		busy = true
		levelCleared()

func _unhandled_input(event):
	if not gameOver:
		return
	var pressed = (event is InputEventScreenTouch and event.pressed)
	pressed = pressed or (event is InputEventMouseButton and event.pressed)
	pressed = pressed or (event is InputEventKey and event.pressed and not event.echo)
	if pressed:
		gameOver = false
		global.resetGame()
		startLevel(0)
