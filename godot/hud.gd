extends CanvasLayer

#Global Variables
@onready var global = get_node("/root/Global")

const BUTTON_SIZE = 128.0
const MARGIN      = 40.0
const dropTexture  = preload("res://ui/btn_drop.svg")
const dropPressed  = preload("res://ui/btn_drop_p.svg")
const fireTexture  = preload("res://ui/btn_fire.svg")
const firePressed  = preload("res://ui/btn_fire_p.svg")

var bannerTime = 0.0
var shownMode  = null

func layoutTouchControls():
	#the touch buttons live in screen space so they have to follow the screen size
	var vp = get_viewport().get_visible_rect().size
	var y  = vp.y - MARGIN - BUTTON_SIZE
	$TouchLeft.position  = Vector2(MARGIN,y)
	$TouchRight.position = Vector2(MARGIN+BUTTON_SIZE+24,y)
	$TouchDrop.position  = Vector2(vp.x-MARGIN-BUTTON_SIZE,y)

func showBanner(text,seconds):
	$Banner.text = text
	$Banner.show()
	bannerTime = seconds

func _ready():
	get_viewport().size_changed.connect(layoutTouchControls)
	layoutTouchControls()
	$Banner.hide()

func _process(delta):
	$Top/Bar/Level.text = "LEVEL %d" % (global.level+1)
	$Top/Bar/Score.text = "SCORE %d" % global.score
	$Top/Bar/Boats.text = "BOATS %d" % max(global.lives,0)
	#the same ammo is dropped on submarines and fired up at aircraft
	if (shownMode!=global.airMode):
		shownMode = global.airMode
		$TouchDrop.texture_normal  = fireTexture if shownMode else dropTexture
		$TouchDrop.texture_pressed = firePressed if shownMode else dropPressed
	$Top/Bar/Ammo.text = "SHELLS %d" % global.ammo if shownMode else "BARRELS %d" % global.ammo
	if (bannerTime>0.0):
		bannerTime -= delta
		if (bannerTime<=0.0):
			$Banner.hide()
