class_name PlayerBoat
extends RigidBody2D

#Global Variables
@onready var global = get_node("/root/Global")
const newBarrelS = preload("res://barrel.tscn") 


var score : int = 0 
var speed : int = 100  
#var ammo : int = 3 
var vel : Vector2 = Vector2()

func _input(event):
	#if event is InputEventKey and event.scancode == KEY_S and not event.echo:
	if Input.is_action_pressed("shoot"):
		if (global.ammo>0):
			global.ammo -= 1
			print("SHOOT")
			var newBarrel =newBarrelS.instantiate()
			newBarrel.position = self.position + Vector2(0,2)
			print(newBarrel.position)
			get_parent().add_child(newBarrel)
			#add_child(newBarrel)

func _physics_process(delta):
	vel.x = 0 
	if Input.is_action_pressed("left"):
		vel.x -=  speed
	if Input.is_action_pressed("right"):
		vel.x +=  speed
		
	set_axis_velocity(vel)


# Called when the node enters the scene tree for the first time.
func _ready():
	global.ammo=3
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
