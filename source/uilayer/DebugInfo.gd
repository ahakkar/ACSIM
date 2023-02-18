class_name DebugInfo
extends GridContainer


@onready var fps_label:Label
@onready var cam_pos_label:Label
@onready var cam_rotation_label:Label
@onready var cam_zoom_label:Label
@onready var chunk_label:Label
@onready var chunk_del_label:Label


func set_ready():
	fps_label = find_child("FPSLabel")	
	cam_pos_label = find_child("CamPosLabel")
	cam_rotation_label = find_child("CamRotationLabel")
	cam_zoom_label = find_child("CamZoomLabel")
	chunk_label = find_child("ChunkLabel")
	chunk_del_label = find_child("ChunkDelLabel")
	

func _process(_delta):
	self.set_fps_label(Engine.get_frames_per_second())
	

func _on_camera_pos_changed(new_pos):
	self.set_cam_pos_label(new_pos)
	

func _on_camera_rotation_changed(new_rotation):
	self.set_cam_rotation(new_rotation)
	

func _on_camera_zoom_changed(new_zoom_factor):
	self.set_cam_zoom_label(new_zoom_factor)
	
	
func _on_chunk_handler_chunk_stats(chunks:int, removal_queue:int):
	if !chunk_label or !chunk_del_label:
		return
	self.set_chunk_label(chunks)
	self.set_chunk_del_label(removal_queue)
	
	
func set_fps_label(info:float) -> void:
	self.fps_label.set_text("FPS: " + str(info))
	
	
func set_cam_pos_label(info:Vector2) -> void:
	if info == null:
		self.cam_pos_label.set_text("Cam pos: unknown")
		return
	self.cam_pos_label.set_text("Cam pos: " + str(info))
	

func set_cam_rotation(info) -> void:
	if info == null:
		self.cam_rotation_label.set_text("Cam rot: unknown")	
		return
	self.cam_rotation_label.set_text("Cam rot: " + str(info))
	
	
func set_cam_zoom_label(info:float) -> void:
	if info == null:
		self.cam_zoom_label.set_text("Zoom : unknown")	
		return
	self.cam_zoom_label.set_text("Zoom :" + str(info))
	
	
func set_chunk_label(info:int) -> void:
	if info == null:
		self.chunk_label.set_text("Chunks: unknown")
		return
	self.chunk_label.set_text("Chunks: " + str(info))
	
	
func set_chunk_del_label(info:int) -> void:
	if info == null:
		self.chunk_del_label.set_text("Chunk del: unknown")
		return
	self.chunk_del_label.set_text("Chunk del: " + str(info))
	



