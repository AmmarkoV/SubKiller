extends RigidBody2D

const newExplosions = preload("res://explosion.tscn")
@onready var global = get_node("/root/Global")

# Called when the node enters the scene tree for the first time.
func _ready():
	self.contact_monitor = true
	self.max_contacts_reported = 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_body_entered(body): 
	print("Contact with ",body.name)
	if body.name == "enemySubmarine":
		var newExplosion = newExplosions.instantiate()
		newExplosion.position = self.position
		print("Explosion Of Enemy Submarine",newExplosion.position)
		get_parent().add_child(newExplosion)
		global.ammo+=1
		global.enemies-=1
		body.queue_free()
		queue_free()
		
	if body.name == "enemyBullet":
		var newExplosion = newExplosions.instantiate()
		newExplosion.position = self.position
		print("Explosion of Enemy Bullet",newExplosion.position)
		get_parent().add_child(newExplosion)
		global.ammo+=1
		body.queue_free()
		queue_free()
		
	if body.name == "bottom":
		var newExplosion = newExplosions.instantiate()
		newExplosion.position = self.position
		print("Explosion after reaching bottom ",newExplosion.position)
		get_parent().add_child(newExplosion)
		global.ammo+=1
		queue_free()
	pass # Replace with function body.
