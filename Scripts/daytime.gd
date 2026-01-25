extends Node2D

@onready var daytime_timer: Timer = $DaytimeTimer

var player : Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	daytime_setup()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	UiManager.daytime_counter_label.text = str(int(daytime_timer.time_left))

# Set up spawns, start timer
func daytime_setup() -> void:
	#TODO: Set up resource spawns
	
	# Grabs player just in case
	player = get_tree().get_first_node_in_group("Player")
	
	# Starts daytime timer
	daytime_timer.start(GameConstants.DAYTIME_LENGTH)


func _on_daytime_timer_timeout() -> void:
	player.is_movement_locked = true
	SignalBus.daytime_end.emit()
	SignalBus.transition.emit()
	var day_end_dialogue = "It's getting late. Better head back..."
	SignalBus.send_dialogue.emit(day_end_dialogue)
	await get_tree().create_timer(3.0).timeout
	SceneController.load_scene(SceneController.transition_screen)
