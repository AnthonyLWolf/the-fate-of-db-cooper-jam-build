extends Node2D


# Global variables
var day : int = 6
var wood_count : int = 0
var leaf_count : int = 0

# Cash variables
var cash_count : int = 200000
var display_cash : int = cash_count
var new_cash : int = cash_count # Initialises all cash valuables to the same value

# End condition variables
var out_of_cash : bool = false
var froze_to_death : bool = false
var survived : bool = false

var player : Node2D

enum GameState {
	GAMESTART,
	DAYTIME,
	NIGHTTIME,
	TRANSITION,
	WIN,
	LOSS
}
var current_state : GameState = GameState.DAYTIME:
	set(value):
		current_state = value
		_on_phase_changed(value) # Runs every time a variable is assigned
var previous_phase : GameState

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.ui_ready.connect(func():
		# Initialises counters on UI ready
		update_ui_counters()
		)
	# Connects functional signals
	SignalBus.cash_burned.connect(update_new_cash)
	SignalBus.nighttime_end.connect(func(): day += 1)
	SignalBus.transition.connect(_start_phase_transition)
	SignalBus.nighttime_end.connect(func(): previous_phase = GameState.NIGHTTIME)
	SignalBus.daytime_end.connect(func(): previous_phase = GameState.DAYTIME)
	
	# Connects endgame signals
	SignalBus.froze_to_death.connect(_freeze_player)
	
	# Grabs player for end conditions
	player = get_tree().get_first_node_in_group("Player")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if day == GameConstants.MAX_DAYS && current_state != GameState.WIN:
		current_state = GameState.WIN
		survived = true
		SceneController.load_scene(SceneController.game_over_screen)
		

func _on_phase_changed(new_state : GameState):
	match new_state:
		GameState.DAYTIME:
			SignalBus.daytime_start.emit()
		GameState.TRANSITION:
			print("Transitioning!")
		GameState.NIGHTTIME:
			SignalBus.nighttime_start.emit()

# Checks cash and triggers end condition if at zero
func update_new_cash(cash_burned):
	new_cash -= cash_burned
	cash_count -= cash_burned
	cash_check()

func cash_check():
	if cash_count <= 0:
		cash_count = 0
		new_cash = 0
		display_cash = 0
		_out_of_cash()

# NOTE: ONLY used to transition between day and night. To change scene use scene_controller.
func _start_phase_transition():
	current_state = GameState.TRANSITION

# Endgame functions
func _freeze_player():
	current_state = GameState.LOSS
	froze_to_death = true
	
	# Plays death animation
	player.animated_sprite_2d.play("freeze")
	await player.animated_sprite_2d.animation_finished
	player.animated_sprite_2d.play("death")
	await player.animated_sprite_2d.animation_finished
	
	# Loads game over screen
	SceneController.load_scene(SceneController.game_over_screen)

func _out_of_cash():
	current_state = GameState.LOSS
	out_of_cash = true
	SignalBus.send_dialogue.emit("Damn! I'm out of dough.")
	await get_tree().create_timer(1.5).timeout
	SceneController.load_scene(SceneController.game_over_screen)

func update_ui_counters():
	# UiManager.cash_counter_label.text = str(cash_count)
	## Animates the cash count
	var cash_tween = create_tween()
	cash_tween.tween_method(
		func(value): UiManager.cash_counter_label.text = str(value),
		display_cash,
		new_cash,
		1.0
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	display_cash = new_cash
	
	UiManager.wood_counter_label.text = str(wood_count)
	UiManager.leaf_counter_label.text = str(leaf_count)
