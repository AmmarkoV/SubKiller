extends RigidBody2D

#Global Variables
@onready var global = get_node("/root/Global")
const newBombConstructor = preload("res://enemy_bullet.tscn")
var timing  = 5.0
var speed   = 0.0
var enemyID = 0
var lastX   = 0.0
var lastY   = 0.0

func _on_timer_timeout():
	print("ENEMY (",enemyID,") SHOOT")
	var newBomb = newBombConstructor.instantiate()
	newBomb.position = self.position + Vector2(0,-35)
	print(newBomb.position)
	get_parent().add_child(newBomb)

# Called when the node enters the scene tree for the first time.
func _ready():
	self.contact_monitor = true
	self.max_contacts_reported = 1
	enemyID = global.enemies
	global.enemies+=1
	#speed  = randf_range(20,100)
	#timing = randf_range(1,5)
	linear_velocity = Vector2(speed,0)
	$Timer.wait_time = timing
	$Timer.start()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(speed > 0):
		scale.x = scale.y * 1
	elif(speed < 0):
		scale.x = scale.y * -1
	
	if (global.loadNewLevel):
		global.enemies-=1
		queue_free()

	if (position.x==lastX and position.y==lastY):
		print("ENEMY (",enemyID,") STOPPED MOVING")
		linear_velocity = Vector2(speed,0)
		set_axis_velocity(linear_velocity)
	#-----------------
	lastX = position.x
	lastY = position.y
	pass

func _on_body_entered(body):
	if body.name == "BorderLeft":
		print("ENEMY (",enemyID,") HIT LEFT WITH SPEED ",speed)
		speed=-1*speed
		linear_velocity = Vector2(speed,0)
		set_axis_velocity(linear_velocity)
	if body.name == "BorderRight":
		print("ENEMY (",enemyID,") HIT RIGHT WITH SPEED ",speed)
		speed=-1*speed
		linear_velocity = Vector2(speed,0)
		set_axis_velocity(linear_velocity)
	pass # Replace with function body.
