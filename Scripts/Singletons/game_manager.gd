extends Node2D

# Global variables
var day : int = 1
var wood_count : int = 0
var leaf_count : int = 0
var cash_count : int = 200000

enum GAMESTATES {
	DAYTIME,
	NIGHTTIME
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.ui_ready.connect(func():
		# Initialises counters on UI ready
		update_ui_counters()
		)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update_ui_counters():
	UiManager.cash_counter_label.text = str(cash_count)
	UiManager.wood_counter_label.text = str(wood_count)
	UiManager.leaf_counter_label.text = str(leaf_count)
