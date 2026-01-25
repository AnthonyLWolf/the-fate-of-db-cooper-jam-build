extends Node2D


# Global variables
var day : int = 1
var wood_count : int = 0
var leaf_count : int = 0

# Cash variables
var cash_count : int = 200000
var display_cash : int = cash_count
var new_cash : int = cash_count # Initialises all cash valuables to the same value

var cold_amount : float = 50.0

enum GameState {
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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.ui_ready.connect(func():
		# Initialises counters on UI ready
		update_ui_counters()
		)
	SignalBus.cash_burned.connect(update_new_cash)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_phase_changed(new_state : GameState):
	match new_state:
		GameState.DAYTIME:
			SignalBus.daytime_start.emit()
		GameState.TRANSITION:
			print("TRANSITIONING!")
		GameState.NIGHTTIME:
			SignalBus.nighttime_start.emit()

func update_new_cash(cash_burned):
	new_cash -= cash_burned
	cash_count -= cash_burned
	cash_check()

func cash_check():
	if cash_count <= 0:
		cash_count = 0
		new_cash = 0
		display_cash = 0
		SignalBus.out_of_cash.emit()
		game_over()

func game_over():
	#TODO: End condition
	pass

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
