extends Node2D

const START_LIVES : int = 3
const START_AMMO  : int = 3

var enemies : int = 0
var lives   : int = START_LIVES
var level   : int = 0
var ammo    : int = START_AMMO
var score   : int = 0

#the sea level moves between levels, and the boat switches between hunting
#submarines below it and shooting at aircraft above it
var waterY   : float = 150.0
var airMode  : bool  = false

func resetGame():
	enemies = 0
	lives   = START_LIVES
	level   = 0
	ammo    = START_AMMO
	score   = 0
