extends RigidBody2D

#Global Variables
@onready var global = get_node("/root/Global")
const newBombConstructor = preload("res://enemy_bullet.tscn")
var speed = 0.0 
var enemyID = 0

func _on_timer_timeout():
	print("ENEMY (",enemyID,") SHOOT")
	var newBomb = newBombConstructor.instantiate()
	newBomb.position = self.position + Vector2(0,-35)
	print(newBomb.position)
	get_parent().add_child(newBomb)

# Called when the node enters the scene tree for the first time.
func _ready():
	enemyID = global.enemies
	global.enemies+=1
	speed = randf_range(20,100)
	linear_velocity = Vector2(speed,0)
	$Timer.wait_time = randf_range(1,5)
	$Timer.start()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (linear_velocity.x==0.0 and linear_velocity.y==0):
		print("ENEMY (",enemyID,") STOPPED MOVING")
		linear_velocity = Vector2(speed,0)
		set_axis_velocity(linear_velocity)
	pass
