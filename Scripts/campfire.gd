extends Node2D

# References
@onready var interact_label: Label = $AnimatedSprite2D/InteractLabel

# Variables
@export var intensity : int = 0

var player : Node2D
var player_in_interaction_range = false
var player_in_warmth_range = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interact_label.visible = false
	player = get_tree().get_nodes_in_group("Player")[0]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	match GameManager.current_state:
		GameManager.GameState.DAYTIME:
			pass
		GameManager.GameState.NIGHTTIME: # Handles nighttime behaviour
			if !player_in_warmth_range:
				GameManager.cold_amount += delta
			
			if Input.is_action_just_pressed("interact") && player_in_interaction_range && player.holding_item:
				
				if GameManager.wood_count > 0 || GameManager.leaf_count > 0 || GameManager.cash_count > 0:
					if intensity < 100:
						for resource in player.inventory:
							if player.inventory[resource] > 0:
								player.inventory[resource] -= 1
								burn_fuel(resource)


func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		interact_label.visible = true
		player_in_interaction_range = true


func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		interact_label.visible = false
		player_in_interaction_range = false

func burn_fuel(fuel_type : String):
	player.item_held.visible = false
	match fuel_type:
		"wood":
			intensity += 30
			GameManager.wood_count -= 1
		"leaves":
			intensity += 10
			GameManager.leaf_count -= 1
		"cash":
			intensity += 50
			var cash_to_burn = randi_range(10000, 20000)
			SignalBus.cash_burned.emit(cash_to_burn)
	
	if intensity >= 100:
		intensity = 100
	
	# Failsafes for counters
	if GameManager.wood_count < 0:
		GameManager.wood_count = 0
	if GameManager.leaf_count < 0:
		GameManager.leaf_count = 0
	if GameManager.cash_count < 0:
		GameManager.cash_count = 0
	
	GameManager.update_ui_counters()
	player.holding_item = false
	
