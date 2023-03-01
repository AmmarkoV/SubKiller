extends RigidBody2D

const newExplosions = preload("res://explosion.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	self.contact_monitor = true
	self.max_contacts_reported = 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _on_body_entered(body): 
	print("Enemy Bullet contact with ",body.name)
	if body.name == "PlayerBoat":
		body.queue_free()
		var newExplosion = newExplosions.instantiate()
		newExplosion.position = self.position
		print("Explosion ",newExplosion.position)
		get_parent().add_child(newExplosion)
		queue_free()
		
	if body.name == "surface":
		#var newExplosion = newExplosions.instantiate()
		#newExplosion.position = self.position
		#print("Explosion ",newExplosion.position)
		#get_parent().add_child(newExplosion)
		queue_free()
