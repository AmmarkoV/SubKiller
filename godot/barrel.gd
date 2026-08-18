class_name Barrel
extends RigidBody2D

const newExplosions = preload("res://explosion.tscn")
@onready var global = get_node("/root/Global")

#escorts carry their own ammunition, their rounds must not top up the boat
var refunds = true

# Called when the node enters the scene tree for the first time.
func _ready():
	self.contact_monitor = true
	self.max_contacts_reported = 2
	if not refunds:
		#escort rounds are lighter than the boat's own charges, and there are a
		#lot of them, so they are quieter too
		$Barrel.scale = Vector2(0.6,0.6)
		$CollisionShape2D.shape = $CollisionShape2D.shape.duplicate()
		$CollisionShape2D.shape.size = Vector2(4,5)
		$barrelDrop.volume_db = -12.0

func explosion():
	var newExplosion = newExplosions.instantiate()
	newExplosion.position = self.position
	if not refunds:
		newExplosion.volume = -14.0
		newExplosion.size   = 0.55
	get_parent().add_child(newExplosion)

func spend():
	if refunds:
		global.ammo = min(global.ammo+1, global.maxAmmo)
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#anti aircraft rounds that hit nothing keep climbing, hand the ammo back
	if (position.y < -40) or (position.y > get_viewport_rect().size.y+40):
		spend()

func _on_body_entered(body):
	if (body is EnemySubmarine) or (body is EnemyAirplane) or (body is EnemyShip):
		#the further away from the boat, the harder the shot, the more it pays
		global.score += 100 + 10*int(abs(body.position.y-global.boatY)/50)
		body.destroy()
	elif body is EnemyBomb:
		global.score += 25
		body.queue_free()
	elif body.name != "bottom":
		return
	explosion()
	spend()
