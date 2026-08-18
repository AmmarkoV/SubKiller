class_name EnemyAirplane
extends RigidBody2D

#Global Variables
@onready var global = get_node("/root/Global")
const newBombConstructor = preload("res://enemy_bullet.tscn")
const newPickup = preload("res://pickup.tscn")
const HALF_WIDTH = 32.0

var level   = 0
var timing  = 4.0
var speed   = 0.0
var depth   = 0.0
var enemyID = 0

func _on_timer_timeout():
	var newBomb = newBombConstructor.instantiate()
	newBomb.position = self.position + Vector2(0,16)
	#the bomb scene rises out of a submarine, an aircraft drops it instead
	newBomb.gravity_scale = 1.0
	get_parent().add_child(newBomb)

# Called when the node enters the scene tree for the first time.
func _ready():
	enemyID = global.enemies
	level   = global.level
	global.enemies += 1
	$Timer.wait_time = timing
	$Timer.start()

func _physics_process(delta):
	#turn around at the edges of whatever screen we ended up on
	var edge = get_viewport_rect().size.x
	if (position.x < HALF_WIDTH) and (speed < 0):
		speed = -speed
	elif (position.x > edge-HALF_WIDTH) and (speed > 0):
		speed = -speed
	linear_velocity = Vector2(speed,0)
	#face the way we are flying
	if (speed > 0):
		$Plane.scale.x = abs($Plane.scale.x)
	elif (speed < 0):
		$Plane.scale.x = -abs($Plane.scale.x)

func destroy():
	global.enemies -= 1
	#a downed aircraft often leaves a weapon crate behind
	if (randf()<0.5):
		var newDrop = newPickup.instantiate()
		newDrop.kind = randi()%3
		newDrop.position = position
		get_parent().call_deferred("add_child",newDrop)
	queue_free()
