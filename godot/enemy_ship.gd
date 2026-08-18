class_name EnemyShip
extends RigidBody2D

#Global Variables
@onready var global = get_node("/root/Global")
const newBombConstructor = preload("res://enemy_bullet.tscn")
const newPickup = preload("res://pickup.tscn")

#a ship on the horizon is far away and looks small, one about to run the boat
#down fills the screen : that is the whole trick behind this level
const FAR_SCALE  = 0.30
const NEAR_SCALE = 1.25

var level   = 0
var timing  = 3.0
var speed   = 60.0
var depth   = 0.0
var enemyID = 0
var startY  = 0.0
var phase   = 0.0

func _on_timer_timeout():
	var newBomb = newBombConstructor.instantiate()
	newBomb.position = self.position + Vector2(0,18)
	newBomb.gravity_scale = 1.0
	get_parent().add_child(newBomb)

# Called when the node enters the scene tree for the first time.
func _ready():
	enemyID = global.enemies
	level   = global.level
	global.enemies += 1
	self.contact_monitor = true
	self.max_contacts_reported = 2
	#each ship needs its own shape, it gets resized as the ship closes in
	$CollisionShape2D.shape = $CollisionShape2D.shape.duplicate()
	startY = position.y
	$Timer.wait_time = timing
	$Timer.start()

func _physics_process(delta):
	phase += delta
	var t = clamp((position.y-startY)/max(global.boatY-startY,1.0), 0.0, 1.0)
	var s = lerp(FAR_SCALE,NEAR_SCALE,t)
	$Ship.scale = Vector2(s,s)
	$CollisionShape2D.shape.size = Vector2(86,14)*s

#A RigidBody2D can only be steered or teleported from here. Writing position
#directly is undone by the physics server on the same frame, which left the ship
#flickering on the spot instead of wrapping, and the level could never be won.
func _integrate_forces(state):
	var vp = get_viewport_rect().size
	state.linear_velocity = Vector2(sin(phase*0.7)*30.0, speed)
	#a ship that gets past the boat comes round again from the horizon
	if (state.transform.origin.y > vp.y+40):
		var wrapped = state.transform
		wrapped.origin = Vector2(randf_range(vp.x*0.1,vp.x*0.9), startY)
		state.transform = wrapped

func destroy():
	global.enemies -= 1
	if (randf()<0.35):
		var newDrop = newPickup.instantiate()
		newDrop.kind = randi()%3
		newDrop.position = position
		get_parent().call_deferred("add_child",newDrop)
	queue_free()

func _on_body_entered(body):
	if body is PlayerBoat:
		body.die()
