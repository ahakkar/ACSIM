class_name ChunkHandler
extends Node2D

# one tilemap is one chunk
# map consists of many chunks
# chunks are loaded to view when needed
# chunks are deleted after they are no longer needed (in view)

# This is done to speed up game loading and avoiding setting one large tilemap in one go
# which is extremely slow in godot 4.0, 4096x4096 takes minutes to fill with set_cell() commands

var chunks:Dictionary = {}
var window_width = DisplayServer.window_get_size(0).x
var distance = abs((window_width/(Globals.CHUNK_SIZE.x*Globals.TILE_SIZE_X)) / 2 +1 )

# for threading
var chunk_queue:Array = []
var mutex:Mutex
var semaphore:Semaphore
var thread:Thread
var exit_thread = false

var _timer:Timer

func _exit_tree():
	mutex.lock()
	exit_thread = true 
	mutex.unlock()

	semaphore.post()
	thread.wait_to_finish()


func _init() -> void:
	self.name = "ChunkHandler"
	

func _on_main_worldgen_ready():
	thread.start(start_chunkgen, Thread.PRIORITY_NORMAL)
	
	# chunk cleanup timer
	_timer = Timer.new()
	add_child(_timer)
	_timer.connect("timeout", _on_timer_timeout, 0)
	_timer.set_wait_time(0.05)
	_timer.set_one_shot(false)
	_timer.start()
	
	
func _on_timer_timeout():
	clean_up_chunks()
	
	
func _process(_delta):
	update_chunks()	
	
	
func _ready():	
	mutex = Mutex.new()
	semaphore = Semaphore.new()
	exit_thread = false
	
	thread = Thread.new()
	

func start_chunkgen():
	while true:		
		semaphore.wait()

		mutex.lock()
		var should_exit = exit_thread # Protect with Mutex.
		mutex.unlock()

		if should_exit:
			break
		
		# work on emptying the generation queue
		if chunk_queue.size() > 0:
			mutex.lock()
			var vars = chunk_queue.pop_front()
			mutex.unlock()

			load_chunk(vars[0].y, vars[0].x, vars[1])
	
func clean_up_chunks():
	mutex.lock()
	for key in chunks:
		var chunk = chunks[key]
		if chunk.should_remove:
			chunk.queue_free()
			chunks.erase(key)
	mutex.unlock()

func correction_factor(d) -> float:
	if Globals.CAMERA_ZOOM_LEVEL < 0.6:
		return d * 2.0	
	elif Globals.CAMERA_ZOOM_LEVEL > 1.0:
		return d
	else:
		return d * ( 1 + 2 * (1-Globals.CAMERA_ZOOM_LEVEL) )


func get_chunk(key:Vector2i):
	if self.chunks.has(key):
		return chunks.get(key)
		
	return null


func load_chunk(y:int, x:int, key):	
	var chunk = Chunk.new(y, x, false)	
	call_deferred("add_child", chunk)
		
	mutex.lock()	
	chunks[key] = chunk	
	mutex.unlock()

	
func update_chunks():	
	var p_x = int(Globals.CAMERA_POSITION.x- Globals.CHUNK_SIZE.x) / Globals.TILE_SIZE_X / Globals.CHUNK_SIZE.x
	var p_y = int(Globals.CAMERA_POSITION.y- Globals.CHUNK_SIZE.y) / Globals.TILE_SIZE_Y / Globals.CHUNK_SIZE.y
	
	# When updating chunks, adjust chunk rendering distance 
	# based on current zoom level.
	var zoom_corrected = correction_factor(distance)

	# iterate through all the chunks. if a chunk is in camera range,
	# and it exists, it should not be removed
	# if chunk should be in range and it doesn't exist, it will be
	# created by adding the coords to a work queue
	for y in Globals.map_size/Globals.CHUNK_SIZE.y:
		for x in Globals.map_size/Globals.CHUNK_SIZE.x:
			
			var key = Vector2i(y,x)
			var chunk = null
			
			if chunks.has(key):	
				chunk = get_chunk(key) 
				
			if (abs(x - p_x) <= zoom_corrected && abs(y - p_y) <= zoom_corrected):				
				if chunk != null:
					chunk.should_remove = false
				else:
					mutex.lock()
					chunk_queue.push_back([Vector2i(x, y), key])
					mutex.unlock()				
					semaphore.post()
			elif chunks.has(key):
				chunks[key].should_remove = true

