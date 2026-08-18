class_name Escort
extends Node2D

#Global Variables
@onready var global = get_node("/root/Global")
const newBarrelS = preload("res://barrel.tscn")

func _on_timer_timeout():
	#the escort carries its own ammunition, it does not eat into the boat's
	var newBarrel = newBarrelS.instantiate()
	newBarrel.refunds = false
	if global.firesUpward():
		newBarrel.position = global_position + Vector2(0,-18)
		newBarrel.gravity_scale = -1.4
	else:
		newBarrel.position = global_position + Vector2(0,16)
	#children of the boat, so the level is one step further up
	get_parent().get_parent().add_child(newBarrel)
