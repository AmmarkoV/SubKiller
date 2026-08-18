extends Node2D

const START_LIVES : int = 3
const START_AMMO  : int = 3

#weapon upgrade limits
const BASE_FIRE_RATE : float = 0.40
const MIN_FIRE_RATE  : float = 0.16
const MAX_AMMO       : int   = 7
const MAX_ESCORTS    : int   = 2

#the three ways a level can be played
const MODE_SEA    : int = 0
const MODE_AIR    : int = 1
const MODE_CONVOY : int = 2

var enemies : int = 0
var lives   : int = START_LIVES
var level   : int = 0
var ammo    : int = START_AMMO
var score   : int = 0

#the sea level moves between levels, and the boat switches between hunting
#submarines below it, shooting at aircraft above it, and facing a convoy
#coming in over the horizon
var waterY  : float = 150.0
var boatY   : float = 154.0
var mode    : int   = MODE_SEA

#weapon upgrades dropped by the aircraft and the convoy
var fireRate : float = BASE_FIRE_RATE
var maxAmmo  : int   = START_AMMO
var escorts  : int   = 0

#one shot text for the HUD, so anything in the game can announce itself
var message : String = ""

func resetGame():
	enemies  = 0
	lives    = START_LIVES
	level    = 0
	ammo     = START_AMMO
	score    = 0
	fireRate = BASE_FIRE_RATE
	maxAmmo  = START_AMMO
	escorts  = 0

#depth charges are dropped on submarines, everything else is shot at
func firesUpward() -> bool:
	return mode != MODE_SEA
