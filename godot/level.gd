extends Node2D

const newPlayerConstructor = preload("res://player_boat.tscn")
const newSubConstructor = preload("res://enemy_submarine.tscn")


func createPlayer():
	var newPlayer = newPlayerConstructor.instantiate()
	newPlayer.position = Vector2(399,149)
	print(newPlayer.position)
	add_child(newPlayer)
	
func createSub(x,y):
	var newSub = newSubConstructor.instantiate()
	newSub.position = Vector2(x,y)
	print(newSub.position)
	add_child(newSub)


# Called when the node enters the scene tree for the first time.
func _ready():
	createPlayer()
	createSub(0,300)
	createSub(100,500)
	createSub(200,600)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
