class_name Barrel
extends RigidBody2D

const newExplosions = preload("res://explosion.tscn")
@onready var global = get_node("/root/Global")

# Called when the node enters the scene tree for the first time.
func _ready():
	self.contact_monitor = true
	self.max_contacts_reported = 2

func explosion():
	var newExplosion = newExplosions.instantiate()
	newExplosion.position = self.position
	get_parent().add_child(newExplosion)

func spend():
	global.ammo += 1
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#anti aircraft rounds that hit nothing keep climbing, hand the ammo back
	if (position.y < -40) or (position.y > get_viewport_rect().size.y+40):
		spend()

func _on_body_entered(body):
	if (body is EnemySubmarine) or (body is EnemyAirplane):
		#the further away from the boat, the harder the shot, the more it pays
		global.score += 100 + 10*int(abs(body.position.y-global.waterY)/50)
		body.destroy()
	elif body is EnemyBomb:
		global.score += 25
		body.queue_free()
	elif body.name != "bottom":
		return
	explosion()
	spend()
