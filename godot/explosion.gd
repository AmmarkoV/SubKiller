class_name Explosion
extends Node2D

#escort rounds go off constantly, they use a smaller and quieter blast
var volume : float = 0.0
var size   : float = 1.0


# Called when the node enters the scene tree for the first time.
func _ready():
	$Explosion.scale = Vector2(size,size)
	$explosionSound.volume_db = volume
	$explosionSound.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_audio_stream_player_finished():
	queue_free()
	pass # Replace with function body.
