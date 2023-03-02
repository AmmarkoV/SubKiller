extends Node2D

#Global Variables
@onready var global = get_node("/root/Global")
const newPlayerConstructor = preload("res://player_boat.tscn")
const newSubConstructor = preload("res://enemy_submarine.tscn")

func createPlayer():
	var newPlayer = newPlayerConstructor.instantiate()
	newPlayer.position = Vector2(399,149)
	print(newPlayer.position)
	add_child(newPlayer)
	
func createSub(x,y,speed,timing):
	var newSub = newSubConstructor.instantiate()
	newSub.position = Vector2(x,y)
	newSub.speed    = speed
	newSub.timing   = timing
	print(newSub.position)
	add_child(newSub)

func startLevel(newLevel):
		global.loadNewLevel = 1
		global.level = newLevel
#-------------------------------------
		if (global.life==0):
			createPlayer()
			global.level = 0
		#--------------------------------
		if (global.level==0):
				createSub(100,500,40,4.0)
		#--------------------------------
		elif (global.level==1):
				createSub(30,300,20,5.0)
				createSub(200,600,80,3.0)
		#--------------------------------
		elif (global.level==2):
				createSub(30,300,20,5.0)
				createSub(100,500,40,4.0)
				createSub(200,600,80,3.0)
		#--------------------------------
		elif (global.level==3):
				createSub(30,300,40,2.0)
				createSub(400,200,60,-3.0)
				createSub(100,500,60,3.0)
				createSub(200,600,100,3.0)
		#--------------------------------
#-------------------------------------
		global.loadNewLevel = 0
#-------------------------------------

# Called when the node enters the scene tree for the first time.
func _ready():
	startLevel(0)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (global.life==0):
		startLevel(global.level)
	if (global.enemies==0):
		global.level += 1
		startLevel(global.level)
	pass
