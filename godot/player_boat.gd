class_name PlayerBoat
extends RigidBody2D

#Global Variables
@onready var global = get_node("/root/Global")
const newBarrelS    = preload("res://barrel.tscn")
const newEscortS    = preload("res://escort.tscn")
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
	$cooldownTimer.wait_time = global.fireRate
	$cooldownTimer.start()
	var newBarrel = newBarrelS.instantiate()
	if global.firesUpward():
		#same ammunition, fired up at the aircraft and the convoy
		newBarrel.position = self.position + Vector2(0,-18)
		newBarrel.gravity_scale = -1.4
	else:
		#dropped just under the waterline so it sinks instead of floating
		newBarrel.position = self.position + Vector2(0,16)
	get_parent().add_child(newBarrel)


func escortCount():
	var found = 0
	for child in get_children():
		if child is Escort:
			found += 1
	return found


func addEscort():
	var newEscort = newEscortS.instantiate()
	newEscort.position = Vector2(-78 if escortCount()==0 else 78, 4)
	add_child(newEscort)


func die():
	var newExplosion = newExplosions.instantiate()
	newExplosion.position = self.position
	get_parent().add_child(newExplosion)
	queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#escorts are picked up mid level, they ride along as children of the boat
	while (escortCount() < global.escorts):
		addEscort()


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
	riding.origin.y = global.boatY
	state.transform = riding
