extends Node2D

# References
@onready var interact_label: Label = $AnimatedSprite2D/InteractLabel
@onready var warmth_shape: CircleShape2D = $WarmthArea/CollisionShape2D.shape
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


# Variables
@export var fire_intensity : float = GameConstants.MAX_WARMTH_RADIUS / 2

# Warmth variables
var warmth_decay_rate = 10.0
var intensity_ratio = 0.5

# Cold variables
var cold_amount : float = 25.0
var cold_decay_rate : float = 1.5
var cold_multiplier : float = float(GameManager.day) * cold_decay_rate

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
			pass # Animate differently
		GameManager.GameState.NIGHTTIME: # Handles nighttime behaviour
			# Instantly checks if cold amount warrants a game over each frame
			if cold_amount >= GameConstants.MAX_COLD_AMOUNT:
				SignalBus.froze_to_death.emit()
				return
			
			# Animates shape radius based on fire intensity
			intensity_ratio = fire_intensity / GameConstants.MAX_WARMTH_RADIUS
			fire_intensity -= warmth_decay_rate * delta
			
			# Failsafe clamp for fire intensity
			if fire_intensity < GameConstants.MIN_WARMTH_RADIUS:
				fire_intensity = GameConstants.MIN_WARMTH_RADIUS
			if fire_intensity > GameConstants.MAX_WARMTH_RADIUS:
				fire_intensity = GameConstants.MAX_WARMTH_RADIUS 
			
			var target_radius = lerp(GameConstants.MIN_WARMTH_RADIUS, GameConstants.MAX_WARMTH_RADIUS, intensity_ratio)
			warmth_shape.radius = target_radius
			
			# Cold mechanic
			if !player_in_warmth_range:
				cold_amount += cold_multiplier * delta
				UiManager.cold_bar.value = cold_amount
			
			# Handles burning of fuel
			if Input.is_action_just_pressed("interact") && player_in_interaction_range && player.holding_item:
				
				if GameManager.wood_count > 0 || GameManager.leaf_count > 0 || GameManager.cash_count > 0:
					if fire_intensity < GameConstants.MAX_WARMTH_RADIUS:
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
			fire_intensity += 250
			GameManager.wood_count -= 1
		"leaves":
			fire_intensity += 100
			GameManager.leaf_count -= 1
		"cash":
			fire_intensity += 400
			var cash_to_burn = randi_range(10000, 20000)
			SignalBus.cash_burned.emit(cash_to_burn)
	
	if fire_intensity >= GameConstants.MAX_WARMTH_RADIUS:
		fire_intensity = GameConstants.MAX_WARMTH_RADIUS
	
	# Failsafes for counters
	if GameManager.wood_count < 0:
		GameManager.wood_count = 0
	if GameManager.leaf_count < 0:
		GameManager.leaf_count = 0
	if GameManager.cash_count < 0:
		GameManager.cash_count = 0
	
	GameManager.update_ui_counters()
	player.holding_item = false


func _on_warmth_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_warmth_range = true


func _on_warmth_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_warmth_range = false
