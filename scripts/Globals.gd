# File contains global variables or constants so they all are in one place instead
# of a million files. So you can adjust them easily from one place if needed.

extends Node

var world_map: TileMap

# FILE PATHS
const SCENE_PATH:String = "res://scenes/"
const ART_PATH:String = "res://art/"
const SCRIPT_PATH:String = "res://scripts"

# NODE NAMES
const WORLD_NODE:String = "World"
const DEBUGINFO_NODE:String = "DebugInfo"
const CONSTRUCTION_PANEL_NODE:String = "ConstructionPanel"

const GUI_BUILD_BUTTON_SIZE_X: int = 50
const GUI_BUILD_BUTTON_SIZE_Y: int = 50
const GUI_BUILD_BUTTON_SIZE: Vector2i =	Vector2i(GUI_BUILD_BUTTON_SIZE_X,GUI_BUILD_BUTTON_SIZE_Y)

# GAME WINDOW DEFAULT SIZE
const DEFAULT_X_RES:int = 1920
const DEFAULT_Y_RES:int = 1080

# maybe should use int for these instead for faster matching?
const TYPE_RESIDENTIAL:String = "residential"
const TYPE_COMMERCIAL:String = "commercial"
const TYPE_INDUSTRIAL:String = "industrial"
const TYPE_SERVICES:String = "services"
const TYPE_SOCIAL:String = "social"
const TYPE_POWERPLANT:String = "powerplant"
const TYPE_ROADS:String = "roads"
const TYPE_DEMOLISH:String = "demolish"

# tilemap layers
const LAYER_TERRAIN:int = 0
const LAYER_BUILDINGS:int = 1

# camera movement settings
var CAMERA_ZOOM_LEVEL: float = 1.0

const CAMERA_MIN_ZOOM_LEVEL: float = 0.1
const CAMERA_MAX_ZOOM_LEVEL: float = 2.0
const CAMERA_ZOOM_FACTOR: float = 0.1
const CAMERA_ZOOM_DURATION: float = 0.1
const CAMERA_PAN_MULTI:float = 2.0

# city map generation file should have black ground (0,0,0) and white water (1,1,1)
const GROUND_TILE_COLOR_IN_MAP_FILE: Color = Color(0,0,0,1)
const WATER_TILE_COLOR_IN_MAP_FILE: Color = Color(1,1,1,1)

# min and max sizes for a map so the map won't be unreasonably small or large
const MAP_MIN_HEIGHT:int = 100
const MAP_MAX_HEIGHT:int = 1000
const MAP_MIN_WIDTH:int = 100
const MAP_MAX_WIDTH:int = 1000

# tile size
const TILE_SIZE_X:int = 16
const TILE_SIZE_Y:int = 16

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


