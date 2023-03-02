extends RigidBody2D

#Global Variables
@onready var global = get_node("/root/Global")
const newExplosions = preload("res://explosion.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	self.contact_monitor = true
	self.max_contacts_reported = 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func explosion():
		var newExplosion = newExplosions.instantiate()
		newExplosion.position = self.position
		get_parent().add_child(newExplosion)

func _on_body_entered(body): 
	print("Enemy Bullet contact with ",body.name)
	if body.name == "PlayerBoat":
		body.queue_free()
		explosion()
		global.life-=1
		queue_free()
		
	if body.name == "surface":
		queue_free()
