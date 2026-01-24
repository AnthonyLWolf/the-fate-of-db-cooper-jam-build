extends Node2D

# Handles stack type
@export var is_wood = false
@export var is_leaf = false
@export var is_cash = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func add_to_stack(fuel_type: String):
	match fuel_type:
		"wood":
			if is_wood:
				GameManager.wood_count += 1
		"leaf":
			if is_leaf:
				GameManager.leaf_count += 1
