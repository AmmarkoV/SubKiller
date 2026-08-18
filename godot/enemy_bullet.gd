class_name EnemyBomb
extends RigidBody2D

const newExplosions = preload("res://explosion.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	self.contact_monitor = true
	self.max_contacts_reported = 2

func explosion():
	var newExplosion = newExplosions.instantiate()
	newExplosion.position = self.position
	get_parent().add_child(newExplosion)

func _on_body_entered(body):
	if body is PlayerBoat:
		body.die()
		explosion()
		queue_free()
	elif body.name == "surface":
		queue_free()
