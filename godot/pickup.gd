class_name Pickup
extends Area2D

#Global Variables
@onready var global = get_node("/root/Global")

const RAPID  = 0
const AMMO   = 1
const ESCORT = 2
const ICONS  = [preload("res://ui/pickup_rapid.svg"),
                preload("res://ui/pickup_ammo.svg"),
                preload("res://ui/pickup_escort.svg")]

var kind = 0
var fall = 110.0

func _ready():
	$Icon.texture = ICONS[kind]

func _process(delta):
	position.y += fall*delta
	$Icon.rotation += delta*1.2
	#a crate that misses the boat is lost
	if (position.y > global.boatY+40):
		queue_free()

func collect():
	if (kind==RAPID):
		global.fireRate = max(global.MIN_FIRE_RATE, global.fireRate-0.06)
		global.message  = "RAPID FIRE"
	elif (kind==AMMO):
		global.maxAmmo = min(global.MAX_AMMO, global.maxAmmo+1)
		global.ammo   += 1
		global.message = "AMMO CAPACITY UP"
	else:
		global.escorts = min(global.MAX_ESCORTS, global.escorts+1)
		global.message = "ESCORT JOINED"
	global.score += 50

func _on_body_entered(body):
	if not (body is PlayerBoat):
		return
	collect()
	#let the sound finish before the crate disappears
	$Icon.hide()
	$CollisionShape2D.set_deferred("disabled",true)
	$pickupSound.play()
	await $pickupSound.finished
	queue_free()
