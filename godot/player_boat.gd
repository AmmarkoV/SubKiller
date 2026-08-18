class_name PlayerBoat
extends RigidBody2D

#Global Variables
@onready var global = get_node("/root/Global")
const newBarrelS    = preload("res://barrel.tscn")
const newExplosions = preload("res://explosion.tscn")

var speed : float = 260.0
var cooldown : int = 0
var direction : float = 0.0


func _on_timer_timeout():
	cooldown = 0


func dropBarrel():
	if (global.ammo<=0) or (cooldown==1):
		return
	global.ammo -= 1
	cooldown = 1
	$cooldownTimer.start()
	var newBarrel = newBarrelS.instantiate()
	if global.airMode:
		#same ammo, fired up at the aircraft instead of dropped on submarines
		newBarrel.position = self.position + Vector2(0,-18)
		newBarrel.gravity_scale = -1.4
	else:
		#spawn it just under the waterline so it sinks instead of resting on the surface
		newBarrel.position = self.position + Vector2(0,16)
	get_parent().add_child(newBarrel)


func die():
	var newExplosion = newExplosions.instantiate()
	newExplosion.position = self.position
	get_parent().add_child(newExplosion)
	queue_free()


func _physics_process(delta):
	direction = Input.get_axis("left","right")
	if Input.is_action_just_pressed("shoot"):
		dropBarrel()


#RigidBody2D movement has to be written from here, otherwise the physics server
#overwrites it : the boat keeps drifting after the key is released, and it sinks
#straight through the waterline while the sea level is being animated.
func _integrate_forces(state):
	state.linear_velocity = Vector2(direction*speed,0.0)
	var riding = state.transform
	riding.origin.y = global.waterY - 2.0
	state.transform = riding
