extends Control

#The story panels, in order. Text is one line per panel, "\n" splits the lines,
#edit them freely - nothing else in the game depends on what is written here.
const PANELS = [
	{"image":preload("res://story/story1.svg"),
	 "text":"THE AEGEAN SEA\nGreece and Turkey are trading words again"},
	{"image":preload("res://story/story2.svg"),
	 "text":"SONAR CONTACT\nSubmarines are slipping between the islands"},
	{"image":preload("res://story/story3.svg"),
	 "text":"AND AT FIRST LIGHT, AIRCRAFT\ncrossing the line over the open water"},
	{"image":preload("res://story/story4.svg"),
	 "text":"ONE PATROL BOAT IS STILL ON STATION\nYours. Good luck out there."},
]

const FADE = 0.7
const HOLD = 2.8

var story = null
var done  = false

func setPanel(panel):
	$Frame/Image.texture = panel["image"]
	$Frame/Caption.text  = panel["text"]

func finish():
	if done:
		return
	done = true
	get_tree().change_scene_to_file("res://level.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	$Frame.modulate.a = 0.0
	#one tween drives the whole sequence, so skipping is just killing it
	story = create_tween()
	for panel in PANELS:
		story.tween_callback(setPanel.bind(panel))
		story.tween_property($Frame,"modulate:a",1.0,FADE)
		story.tween_interval(HOLD)
		story.tween_property($Frame,"modulate:a",0.0,FADE)
	story.tween_callback(finish)

func _unhandled_input(event):
	var pressed = (event is InputEventScreenTouch and event.pressed)
	pressed = pressed or (event is InputEventMouseButton and event.pressed)
	pressed = pressed or (event is InputEventKey and event.pressed and not event.echo)
	if pressed:
		if story:
			story.kill()
		finish()
