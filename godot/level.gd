extends Node2D

#Global Variables
@onready var global = get_node("/root/Global")
const newPlayerConstructor = preload("res://player_boat.tscn")
const newSubConstructor = preload("res://enemy_submarine.tscn")
const newPlaneConstructor = preload("res://enemy_airplane.tscn")
const newShipConstructor = preload("res://enemy_ship.tscn")

#The world is laid out relative to the current screen size. The waterline moves
#from level to level, everything else is measured against it.
const SEABED_H   = 100.0
const SKY_BAND   = 150.0
const SUB_MARGIN = 60.0
const AIR_MARGIN = 70.0
const SKY_MARGIN = 60.0
const BOAT_DRAFT = 4.0
const CONVOY_BOAT_GAP = 110.0

#One entry per level :
#  water   = waterline, as a fraction of the screen height
#  mode    = 0 submarine hunt, 1 aircraft raid, 2 convoy coming over the horizon
#  enemies = [ across (0..1) , depth/altitude (0..1) , speed px/sec , seconds between shots ]
const LEVELS = [
	{"water":0.23,"mode":0,"enemies":[ [0.10,0.55, 50,4.2] ]},
	{"water":0.23,"mode":0,"enemies":[ [0.10,0.25, 45,4.5], [0.75,0.70, 80,3.6] ]},
	{"water":0.30,"mode":0,"enemies":[ [0.05,0.20, 65,4.0], [0.60,0.50,-55,3.6], [0.30,0.85, 90,3.2] ]},
	{"water":0.62,"mode":1,"enemies":[ [0.10,0.40,130,3.6], [0.80,0.70,-150,3.2] ]},
	{"water":0.18,"mode":0,"enemies":[ [0.15,0.30, 80,3.2], [0.85,0.60,-70,3.2], [0.45,0.90,115,2.8] ]},
	{"water":0.28,"mode":2,"enemies":[ [0.20,0.10, 55,3.2], [0.70,0.45, 65,3.0] ]},
	{"water":0.35,"mode":0,"enemies":[ [0.10,0.15,100,2.8], [0.50,0.45,-90,2.8], [0.90,0.75, 80,2.4], [0.30,0.95,125,2.6] ]},
	{"water":0.66,"mode":1,"enemies":[ [0.05,0.25,180,2.8], [0.50,0.55,-170,2.8], [0.90,0.80,190,2.4] ]},
	{"water":0.25,"mode":0,"enemies":[ [0.20,0.35,-125,2.3], [0.70,0.35,125,2.3], [0.20,0.80,100,2.3], [0.70,0.80,-100,2.3] ]},
	{"water":0.30,"mode":2,"enemies":[ [0.15,0.05, 65,2.8], [0.50,0.35, 75,2.6], [0.85,0.60, 60,2.8] ]},
	{"water":0.30,"mode":0,"enemies":[ [0.05,0.20,145,2.0], [0.95,0.40,-145,2.0], [0.05,0.60,135,2.0], [0.95,0.85,-135,2.0] ]},
	{"water":0.60,"mode":1,"enemies":[ [0.10,0.20,200,2.3], [0.40,0.50,-190,2.3], [0.70,0.35,210,2.0], [0.95,0.75,-180,2.3] ]},
	{"water":0.20,"mode":0,"enemies":[ [0.10,0.25,155,1.8], [0.40,0.45,-135,1.8], [0.70,0.65,165,1.6], [0.25,0.85,-145,1.6], [0.90,0.95,125,1.8] ]},
]

#past the handmade levels the modes keep cycling in this order
const ENDLESS_MODES = [0,0,1,0,2]

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
	var mode = ENDLESS_MODES[newLevel%ENDLESS_MODES.size()]
	var data = []
	for i in min(4+extra,9):
		var speed = rng.randf_range(110,min(110+22*extra,270))
		if (mode==global.MODE_AIR):
			speed *= 1.4
		elif (mode==global.MODE_CONVOY):
			speed = rng.randf_range(55,min(55+6*extra,130))
		if (mode!=global.MODE_CONVOY) and (rng.randi()%2==0):
			speed = -speed
		data.append([rng.randf_range(0.05,0.95), rng.randf_range(0.05,0.95),
					 speed, max(1.1,1.9-0.05*extra)])
	var water = 0.62 if mode==global.MODE_AIR else rng.randf_range(0.18,0.35)
	return {"water":water,"mode":mode,"enemies":data}

func createPlayer():
	player = newPlayerConstructor.instantiate()
	player.position = Vector2(get_viewport_rect().size.x*0.5, global.boatY)
	add_child(player)

func createEnemy(x,depth,speed,timing):
	var newEnemy = null
	if (global.mode==global.MODE_AIR):
		newEnemy = newPlaneConstructor.instantiate()
	elif (global.mode==global.MODE_CONVOY):
		newEnemy = newShipConstructor.instantiate()
	else:
		newEnemy = newSubConstructor.instantiate()
	newEnemy.position = Vector2(x,enemyY(depth))
	newEnemy.depth    = depth
	newEnemy.speed    = speed
	newEnemy.timing   = timing
	add_child(newEnemy)

func clearLevel():
	for child in get_children():
		if (child is EnemySubmarine) or (child is EnemyAirplane) or (child is EnemyShip) \
		or (child is Barrel) or (child is EnemyBomb) or (child is Pickup):
			child.queue_free()
	global.enemies = 0

#the animated switch between a submarine hunt, an aircraft raid and a convoy
func changeSeaLevel(data):
	var rising = (data["water"] < waterFrac)
	if (abs(data["water"]-waterFrac)<0.01) and (data["mode"]==global.mode):
		return
	$sonarSound.play()
	if (data["mode"]==global.MODE_AIR):
		$HUD.showBanner("AIRCRAFT INBOUND\nTHE SEA IS DRAINING", 0.0)
	elif (data["mode"]==global.MODE_CONVOY):
		$HUD.showBanner("CONVOY ON THE HORIZON\nHOLD THE LINE", 0.0)
	elif rising:
		$HUD.showBanner("THE SEA IS RISING\nSUBMARINES RETURNING", 0.0)
	else:
		$HUD.showBanner("THE SEA IS FALLING", 0.0)
	global.mode = data["mode"]
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
	global.ammo = global.maxAmmo
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
	#aircraft fly between the top of the screen and the waterline, submarines
	#sit between the waterline and the sea bed, and the convoy comes in from
	#the horizon towards the boat in the foreground
	var vp = get_viewport_rect().size
	if (global.mode==global.MODE_AIR):
		return SKY_MARGIN + depth*(global.waterY-AIR_MARGIN-SKY_MARGIN)
	if (global.mode==global.MODE_CONVOY):
		return global.waterY + depth*80.0
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
	var convoy = (global.mode==global.MODE_CONVOY)
	global.waterY = waterFrac*vp.y
	#looking across the sea at the convoy, the boat is in the foreground,
	#otherwise it sits in the water with a few pixels of hull under the surface
	global.boatY = (vp.y-CONVOY_BOAT_GAP) if convoy else (global.waterY+BOAT_DRAFT)

	$SkyBack.position = Vector2.ZERO
	$SkyBack.size     = vp
	stretchSprite($sky/Sky,global.waterY-SKY_BAND,SKY_BAND,Vector2(512,64))
	stretchSprite($rockBottom/RockBottom,vp.y-SEABED_H,SEABED_H,Vector2(512,64))

	$sky.position = Vector2.ZERO
	$sky.scale    = Vector2.ONE
	$rockBottom.position = Vector2.ZERO
	$rockBottom.scale    = Vector2.ONE
	#there is no sea bed in view when the sea is seen from the boat's own deck
	$rockBottom.visible = not convoy
	$bottom.visible     = not convoy

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
	global.mode = LEVELS[0]["mode"]
	waterFrac   = LEVELS[0]["water"]
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
