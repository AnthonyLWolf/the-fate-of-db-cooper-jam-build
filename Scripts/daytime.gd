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

# Set up spawns, start timer
func daytime_setup() -> void:
	# Spawns resources at random distance from the campfire
	spawn_resources(GameManager.day)
	
	# Grabs player just in case
	player = get_tree().get_first_node_in_group("Player")
	
	# Starts daytime timer
	await get_tree().create_timer(1.0).timeout
	send_daily_dialogue()
	await get_tree().create_timer(3.0).timeout
	daytime_timer.start(GameConstants.DAYTIME_LENGTH)

func spawn_resources(current_day : int):
	var base_count = 60
	var spawn_count = base_count - (current_day * (current_day - 1))
	spawn_count = max(spawn_count, 30)
	
	# Divides the forest in chunks to avoid spawn clusters
	var forest_width = 10000
	var step_size = forest_width / spawn_count # Very clever solution!
	
	for i in range(spawn_count):
		# Creates a new resource to prepare spawn
		var item = fuel_resource_scene.instantiate()
		
		# Picks side and initiates coordinate calculation
		var side = 1 if randf() > 0.5 else -1
		var origin = campfire.global_position
		var base_distance = 800 + (i * step_size)
		
		# Makes the chunks less like a straight line
		var jitter = randf_range(-step_size * 0.8, step_size * 0.8)
		var final_distance = (base_distance + jitter) * side
		# var horizontal_offset = distance * side # Adds an offset from the campfire, origin added later
		var vertical_offset = randf_range(-50, 30) # Adds vertical offset for a little perspective variety
		
		# Sets position and performs spawn
		item.global_position = origin + Vector2(final_distance, vertical_offset)
		fuel_resources_container.add_child(item)

func send_daily_dialogue():
	match GameManager.day:
		1:
			SignalBus.send_dialogue.emit("Sh*t. That was a rough landing.")
			await get_tree().create_timer(3.0).timeout
			SignalBus.send_dialogue.emit("Looks like it'll be night soon. Gotta find something to keep me warm.")
		2:
			SignalBus.send_dialogue.emit("New day... Tonight may be worse. Gotta find more stuff.")
		5:
			SignalBus.send_dialogue.emit("I think the blizzard's getting worse. Tonight will be tough.")
		6:
			SignalBus.send_dialogue.emit("Just one more day. C'mon.")

func _on_daytime_timer_timeout() -> void:
	player.is_movement_locked = true
	SignalBus.daytime_end.emit()
	SignalBus.transition.emit()
	var day_end_dialogue = "It's getting late. Better head back..."
	SignalBus.send_dialogue.emit(day_end_dialogue)
	await get_tree().create_timer(3.0).timeout
	SceneController.load_scene(SceneController.transition_screen)
