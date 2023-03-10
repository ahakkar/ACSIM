# File contains global variables or constants so they all are in one place instead
# of a million files. So you can adjust them "easily" from one place if needed.

extends Node

var chunks_loaded:int = 0

###################################
# VARIABLE GAME DATA, saved		  #
###################################

# map size is based on input image x*y pixel size
@export var map_size:int

# store terrain type (water, land, forest etc. for every map cell)
@export var map_terrain_data:Array[PackedInt32Array] = [[]]

# preprocess and store exact tile for every map cell to speed up setting tiles
@export var map_tile_data:Array[Array] = [[]]

# list of parcels the map is divided to
@export var map_parcel_data:Array[Array] = [[]]

# current camera zoom level
@export var CAMERA_ZOOM_LEVEL:float = 1.0
@export var CAMERA_POSITION:Vector2i

# minimap texture, used also as save game's imagetexture
@export var minimap_texture:ImageTexture = null


###################################
# FILE PATHS					  #
###################################

const SCENE_PATH:String = "res://scenes/"
const ART_PATH:String = "res://art/"
const SCRIPT_PATH:String = "res://scripts"


###################################
# CAMERA SETTINGS				  #
###################################

# minimap camera marker sprite
var camera_marker:Sprite2D

# GAME WINDOW DEFAULT SIZE
const DEFAULT_X_RES:int = 1920
const DEFAULT_Y_RES:int = 1080

# camera movement settings
const CAMERA_MIN_ZOOM_LEVEL: float = 0.1
const CAMERA_MAX_ZOOM_LEVEL: float = 2.0
const CAMERA_ZOOM_FACTOR: float = 0.1
const CAMERA_ZOOM_DURATION: float = 0.1
const CAMERA_PAN_MULTI:float = 2.0


###################################
# WORLD GENERATION SETTINGS		  #
###################################

# city map generation file should have black ground (0,0,0) and white water (1,1,1)
const GROUND_TILE_COLOR_IN_MAP_FILE: Color = Color(0,0,0)
const WATER_TILE_COLOR_IN_MAP_FILE: Color = Color(1,1,1)

# min and max sizes for a map so the map won't be unreasonably small or large
const MAP_MIN_HEIGHT:int = 256
const MAP_MAX_HEIGHT:int = 4096
const MAP_MIN_WIDTH:int = 256
const MAP_MAX_WIDTH:int = 4096

# tile size
const TILE_SIZE_X:int = 16
const TILE_SIZE_Y:int = 16

const INFOLAYER_PARCEL_BORDER:Color = Color8(200,25,25,220)
const INFOLAYER_PARCEL_FILL:Color = Color8(128,128,128,220)

# parcel info is saved to a struct
class Parcel:
	var start:Vector2i
	var size:Vector2i
	var owner:int
	var value:float

# parcel size
const PARCEL_WIDTH:int = 16
const PARCEL_HEIGHT:int = 64

var STARTING_AREA_WIDTH_IN_PARCELS:int = 5
var STARTING_AREA_HEIGHT_IN_PARCELS:int = 2

# tile dict to tilemap
var td = {
	TILE_WATER: {
		"default": [Vector2i(1,0)]
		},
	TILE_TERRAIN: {
		"default": [Vector2i(0,0)],
		# 4 land tiles around water
		[1,1,1,1]: [Vector2i(0,0)],
		# 3 land tiles around water
		[1,1,1,0]: [Vector2i(0,0)], 
		[1,1,0,1]: [Vector2i(0,0)], 
		[1,0,1,1]: [Vector2i(0,0)], 
		[0,1,1,1]: [Vector2i(0,0)], 
		# 2 land tiles around water		
		[1,1,0,0]: [Vector2i(11,0), Vector2i(12,0)],
		[0,1,1,0]: [Vector2i(7,0), Vector2i(8,0)],
		[0,0,1,1]: [Vector2i(19,0), Vector2i(20,0)],
		[1,0,0,1]: [Vector2i(15,0), Vector2i(16,0)],
			# 1 land tile around water
		[0,0,0,1]: [Vector2i(17,0), Vector2i(18,0)],
		[0,0,1,0]: [Vector2i(5,0), Vector2i(6,0)],
		[0,1,0,0]: [Vector2i(9,0), Vector2i(10,0)],
		[1,0,0,0]: [Vector2i(13,0), Vector2i(14,0)],
		},
	TILE_FOREST: {
		"default": [Vector2i(5,1)],
		# 4 forest tiles around land
		[2,2,2,2]: [Vector2i(5,1)],
		# 3 forest tiles around land
		[2,2,2,1]: [Vector2i(5,1)],
		[2,2,1,2]: [Vector2i(5,1)],
		[2,1,2,2]: [Vector2i(5,1)],
		[1,2,2,2]: [Vector2i(5,1)],
		# 2 forest tiles around land
		[2,2,1,1]: [Vector2i(28,0)],
		[1,2,2,1]: [Vector2i(26,0)],
		[1,1,2,2]: [Vector2i(24,0)],
		[2,1,1,2]: [Vector2i(22,0)],	
		# 1 forest tile around land
		[1,1,1,2]: [Vector2i(23,0)],
		[1,1,2,1]: [Vector2i(25,0)],
		[1,2,1,1]: [Vector2i(27,0)],
		[2,1,1,1]: [Vector2i(29,0)],
		},
	TILE_BOG: {
		"key": [Vector2i(0,0)]
		}
	}


###################################
# CHUNK AND TERRAIN SETTINGS	  #
###################################

# world map chunk size
const CHUNK_SIZE:Vector2i = Vector2i(32,32)

# tilemap tile types
enum {TILE_WATER, TILE_TERRAIN, TILE_FOREST, TILE_BOG}

# parcel owner types
enum {PARCEL_CITY, PARCEL_STATE, PARCEL_PRIVATE}

# tilemap layers
enum {LAYER_TERRAIN, LAYER_BUILDINGS}
const TILESET_TERRAIN:TileSet = preload("res://scenes/Chunk.tres")


###################################
# MAIN MENU SETTINGS			  #
###################################


###################################
# INFOLAYER SETTINGS			  #
###################################

enum {
	INFOLAYER_PARCELS,
	INFOLAYER_LAND_VALUE,
	INFOLAYER_ZONETYPES,
	INFOLAYER_TRAFFIC,
	INFOLAYER_NOISE,
	INFOLAYER_POLLUTION,
	INFOLAYER_GARBAGE,
	INFOLAYER_HAPPINESS,
	INFOLAYER_EDUCATION,
	INFOLAYER_CRIME,
	INFOLAYER_FIRE,
	INFOLAYER_HEAT,
	INFOLAYER_WATER,
	INFOLAYER_SNOW,
	INFOLAYER_DISTRICTS,
	}

const INFLAYER_LAYERS_HIDDEN:int = -1

###################################
# UI ELEMENT SETTINGS			  #
###################################

# NODE NAMES
const WORLD_NODE:String = "World"
const DEBUGINFO_NODE:String = "DebugInfo"
const CONSTRUCTION_PANEL_NODE:String = "ConstructionPanel"

const GUI_BUILD_BUTTON_SIZE_X: int = 50
const GUI_BUILD_BUTTON_SIZE_Y: int = 50
const GUI_BUILD_BUTTON_SIZE: Vector2i =	Vector2i(GUI_BUILD_BUTTON_SIZE_X,GUI_BUILD_BUTTON_SIZE_Y)

# maybe should use int for these instead for faster matching?
# ^ yes TODO switch to enum
const TYPE_RESIDENTIAL:String = "residential"
const TYPE_COMMERCIAL:String = "commercial"
const TYPE_INDUSTRIAL:String = "industrial"
const TYPE_SERVICES:String = "services"
const TYPE_SOCIAL:String = "social"
const TYPE_POWERPLANT:String = "powerplant"
const TYPE_ROADS:String = "roads"
const TYPE_DEMOLISH:String = "demolish"

# Main menu buttons
enum {
	MAINMENU_NEW_GAME, 
	MAINMENU_LOAD_GAME,
	MAINMENU_RESUME_GAME,
	MAINMENU_OPTIONS, 
	MAINMENU_CREDITS,
	MAINMENU_QUIT_GAME,
	}
	

###################################
# MINIMAP SETTINGS				  #
###################################

var minimap_colors:Dictionary = {
	Globals.TILE_WATER  : Color8(42, 31, 255),
	Globals.TILE_TERRAIN: Color8(148, 113, 71),
	Globals.TILE_FOREST : Color8(0,123,19),
	"default": Color8(255,0,255),
}

	
###################################
# GAME ERORR MESSAGES			  #
###################################

# error messages
const ERROR_BUILDING_TYPE_NOT_SET:String = "Building type not set, while trying to place building."
const ERROR_BUTTON_NOT_FOUND:String = "Button '%s' not found when trying to set it's properties in Control.gd!"
const ERROR_FAILED_TO_LOAD_FILE:String = "Failed to load image with filename: '%s'"
const ERROR_TILE_X_COORDS_OUT_OF_BOUNDS:String = "Trying to build outside the game area: '%s'. Cell should be between '%s-%s'"
const ERROR_TILE_Y_COORDS_OUT_OF_BOUNDS:String = "Trying to build outside the game area: y is: '%s'. Cell should be between '%s-%s'"
const ERROR_IMAGE_WIDTH_INCORRECT:String = "Provided map image width '%s' too small or too large. Width should be between: '%s-%s'"
const ERROR_IMAGE_HEIGHT_INCORRECT:String = "Provided map image height '%s' too small or too large. Height should be between: '%s-%s'"
const ERROR_MAKING_WORLD_INSTANCE:String = "Error while making an instance of World node."
const ERROR_WHILE_GENERATING_MAP:String = "Error in generating the map. Game won't start."
const ERROR_WORLD_TILEMAP_NODE_MISSING:String = "World TileMap node missing or name is wrong. Tried to load: '%s'"


