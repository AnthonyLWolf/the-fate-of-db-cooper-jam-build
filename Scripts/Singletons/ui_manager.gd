extends Control

@onready var cold_bar: ProgressBar = %ColdBar
@onready var wood_counter_label: Label = %WoodCounterLabel
@onready var leaf_counter_label: Label = %LeafCounterLabel
@onready var cash_counter_label: Label = %CashCounterLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.ui_ready.emit()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
