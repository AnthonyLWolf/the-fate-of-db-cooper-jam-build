extends Node2D

# General
signal ui_ready
signal pickup_requested(fuel_type : String, sender: Node2D)
signal pickup_successful(fuel_type : String)
signal cash_burned

# Phase signals
signal daytime_start
signal daytime_end
signal nighttime_start
signal nighttime_end
signal transition

# Player signals
signal send_dialogue

# End condition
signal out_of_cash
signal froze_to_death
signal game_over

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
