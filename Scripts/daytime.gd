extends Node2D

# References
@onready var daytime_timer: Timer = $DaytimeTimer
@onready var campfire = %Campfire
@onready var fuel_resources_container: Node2D = $FuelResources

var fuel_resource_scene = preload("res://Scenes/Classes/fuel_resource.tscn")

var player : Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	daytime_setup()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	UiManager.daytime_counter_label.text = str(int(daytime_timer.time_left))

# Set up spawns, start timer, start ambient and music
func daytime_setup() -> void:
	# Handles music
	if AudioManager.daytime_music_player.playing:
		AudioManager.daytime_music_player.stop()
	
	if !AudioManager.daytime_music_player.playing:
		AudioManager.daytime_music_player.stream = AudioManager.daytime_track
		AudioManager.daytime_music_player.play()
	
	# Plays daytime forest ambience
	if AudioManager.base_ambience_player.playing:
		AudioManager.base_ambience_player.stop()
	if !AudioManager.base_ambience_player.playing:
		AudioManager.base_ambience_player.stream = AudioManager.forest_day_env
		AudioManager.base_ambience_player.play()
		
	# Spawns resources at random distance from the campfire
	spawn_resources(GameManager.day)
	
	# Grabs player just in case and handles behaviour
	player = get_tree().get_first_node_in_group("Player")
	
	## Parachuting functionality, cool for flavour but buggy
	#if GameManager.day == 1:
		#SignalBus.parachute.emit()
	
	# Emits zoom out signal for camera
	await get_tree().create_timer(1.0).timeout
	SignalBus.zoom_out.emit()
	
	# Sends dialogue depending on day
	send_daily_dialogue()
	
	# Starts daily timer after dialogue is read
	await get_tree().create_timer(3.0).timeout
	daytime_timer.start(GameConstants.DAYTIME_LENGTH)

func spawn_resources(current_day : int):
	var base_count = 30
	var spawn_count = base_count - (current_day * (current_day - 1))
	spawn_count = max(spawn_count, 20)
	
	# Divides the forest in chunks to avoid spawn clusters
	var forest_width = 7500
	var step_size = forest_width / spawn_count # Very clever solution!
	
	for i in range(spawn_count):
		# Creates a new resource to prepare spawn
		var item = fuel_resource_scene.instantiate()
		
		# Picks side and initiates coordinate calculation
		var side = 1 if randf() > 0.5 else -1
		var origin = Vector2(campfire.global_position.x, campfire.global_position.y + 50)
		var base_distance = 800 + (i * step_size)
		
		# Makes the chunks less like a straight line
		var jitter = randf_range(-step_size * 0.8, step_size * 0.8)
		var final_distance = (base_distance + jitter) * side
		# var horizontal_offset = distance * side # Adds an offset from the campfire, origin added later
		var vertical_offset = randf_range(-50, 50) # Adds vertical offset for a little perspective variety
		
		# Sets position and performs spawn
		item.global_position = origin + Vector2(final_distance, vertical_offset)
		fuel_resources_container.add_child(item)

func send_daily_dialogue():
	match GameManager.day:
		1:
			SignalBus.send_dialogue.emit("Well. That was a rough landing.")
			await get_tree().create_timer(3.0).timeout
			SignalBus.send_dialogue.emit("Looks like it'll be night soon. Gotta find something to keep me warm.")
		2:
			SignalBus.send_dialogue.emit("New day. Tonight may be worse. Gotta find more stuff.")
		3:
			SignalBus.send_dialogue.emit("I think the blizzard's getting worse. Tonight will be rough.")
		4:
			SignalBus.send_dialogue.emit("Just one more day. C'mon.")

func _on_daytime_timer_timeout() -> void:
	player.is_movement_locked = true
	SignalBus.daytime_end.emit()
	SignalBus.transition.emit()
	var day_end_dialogue : String
	
	# Handles item fate if too far from home
	## Drops items
	if player.distance_from_home >= 10:
		day_end_dialogue = "It's getting late. Camp's too far... I'll have to drop whatever I'm carrying."
		# Resets player inventory
		for resource in player.inventory:
			player.inventory[resource] = 0
	## Keeps items
	elif player.distance_from_home < 10:
		day_end_dialogue = "It's getting late. Camp's close... I'll keep whatever I'm carrying."
		if player.inventory["wood"] > 0:
			GameManager.wood_count += player.inventory["wood"]
		if player.inventory["leaves"] > 0:
			GameManager.leaf_count += player.inventory["leaves"]
		# Resets player inventory
		for resource in player.inventory:
			player.inventory[resource] = 0
	
	SignalBus.send_dialogue.emit(day_end_dialogue)
	await get_tree().create_timer(3.0).timeout
	AudioManager.stop_all_players()
	SceneController.load_scene(SceneController.transition_screen)
