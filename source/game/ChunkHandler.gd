class_name ChunkHandler
extends Node2D

# one tilemap is one chunk
# map consists of many chunks
# chunks are loaded to view when needed
# chunks are deleted after they are no longer needed (in view)

# This is done to speed up game loading and avoiding setting one large tilemap in one go
# which is extremely slow in godot 4.0, 4096x4096 takes minutes to fill with set_cell() commands


signal chunk_stats(chunks:int, removal_queue:int)

var chunks:Dictionary = {}
var chunks_to_remove:Array[Chunk] = []
var window_width:int = DisplayServer.window_get_size(0).x
var distance:int = abs((window_width/(Globals.CHUNK_SIZE.x*Globals.TILE_SIZE_X)) / 2 +1 )

# for threading
var chunk_queue:Array = []
var mutex:Mutex
var semaphore:Semaphore
var thread:Thread
var exit_thread:bool = false


func _exit_tree():
	if !thread:
		return
	mutex.lock()
	exit_thread = true 
	mutex.unlock()

	semaphore.post()
	thread.wait_to_finish()	


func _init() -> void:
	self.name = "ChunkHandler"
	
	
func clean_up_chunks():
	while true:		
		if not chunks_to_remove.is_empty():
			mutex.lock()
			var chunk = chunks_to_remove.pop_front()	
			mutex.unlock()
			chunk.queue_free()
			
		await get_tree().create_timer(0.02).timeout


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
	var chunk = Chunk.new(y, x)	
	call_deferred("add_child", chunk)
		
	mutex.lock()	
	chunks[key] = chunk	
	mutex.unlock()


func process_delay_chunks() -> void:
	while true:
		update_chunks()	
		await get_tree().create_timer(0.05).timeout
		

func process_delay_stats() -> void:
	# emit stats about chunk amounts every 0,5s
	while true:
		emit_signal("chunk_stats", self.chunks.size(), self.chunks_to_remove.size())
		await get_tree().create_timer(0.5).timeout	
	

func set_ready():
	mutex = Mutex.new()
	semaphore = Semaphore.new()
	exit_thread = false
	
	if !thread:
		thread = Thread.new()
		
	if !thread.is_started():
		thread.start(start_chunkgen, Thread.PRIORITY_NORMAL)
		clean_up_chunks()
	
	process_delay_chunks()
	process_delay_stats()


func start_chunkgen():
	while true:		
		semaphore.wait()

		mutex.lock()
		var should_exit = exit_thread # Protect with Mutex.
		mutex.unlock()

		if should_exit:
			break
		
		# work on emptying the generation queue
		if not chunk_queue.is_empty():
			mutex.lock()
			var vars = chunk_queue.pop_front()
			mutex.unlock()

			load_chunk(vars[0].y, vars[0].x, vars[1])

	
func update_chunks():	
	var p_x:float = int(Globals.CAMERA_POSITION.x- Globals.CHUNK_SIZE.x) / Globals.TILE_SIZE_X / Globals.CHUNK_SIZE.x
	var p_y:float = int(Globals.CAMERA_POSITION.y- Globals.CHUNK_SIZE.y) / Globals.TILE_SIZE_Y / Globals.CHUNK_SIZE.y
	
	# When updating chunks, adjust chunk rendering distance 
	# based on current zoom level.
	var zoom_corrected:float = correction_factor(distance)

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
				if chunk == null:	
					mutex.lock()
					chunk_queue.push_back([Vector2i(x, y), key])
					mutex.unlock()				
					semaphore.post()
					
			elif chunks.has(key):
				chunks_to_remove.append(chunks.get(key))
				chunks.erase(key)

