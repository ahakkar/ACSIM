extends Node

const SCENE_PATH:String = "res://scenes/"
const ART_PATH:String = "res://art/"
const SCRIPT_PATH:String = "res://scripts"

const GUI_BUILD_BUTTON_SIZE_X: int = 50
const GUI_BUILD_BUTTON_SIZE_Y: int = 50
const GUI_BUILD_BUTTON_SIZE: Vector2i =	Vector2i(GUI_BUILD_BUTTON_SIZE_X,GUI_BUILD_BUTTON_SIZE_Y)

const DEFAULT_X_RES:int = 1920
const DEFAULT_Y_RES:int = 1080

const TYPE_RESIDENTIAL = "residential"
const TYPE_COMMERCIAL = "commercial"
const TYPE_INDUSTRIAL = "industrial"
const TYPE_SERVICES = "services"
const TYPE_SOCIAL = "social"
const TYPE_POWERPLANT = "powerplant"
const TYPE_ROADS = "roads"
const TYPE_DEMOLISH = "demolish"

# camera movement settings
var CAMERA_ZOOM_LEVEL : float = 1.0

const CAMERA_MIN_ZOOM_LEVEL: float = 0.1
const CAMERA_MAX_ZOOM_LEVEL: float = 2.0
const CAMERA_ZOOM_FACTOR: float = 0.1
const CAMERA_ZOOM_DURATION: float = 0.1
const CAMERA_PAN_MULTI:float = 2.0
