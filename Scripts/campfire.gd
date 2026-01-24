extends Node2D

# References
@onready var interact_label: Label = $AnimatedSprite2D/InteractLabel

# Variables
@export var intensity = 0

var player_in_interaction_range = false
var player_in_warmth_range = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interact_label.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player_in_warmth_range = false 
	
	if Input.is_action_just_pressed("interact") && player_in_interaction_range:
		
		if GameManager.wood_count >= 0 || GameManager.leaf_count >= 0:
			# TEST ONLY, CHANGE TO ALLOW FOR MULTIPLE RESOURCES
			GameManager.wood_count -= 1
			
			# Failsafes for counters
			if GameManager.wood_count < 0:
				GameManager.wood_count = 0
			if GameManager.leaf_count < 0:
				GameManager.leaf_count = 0
			if GameManager.cash_count < 0:
				GameManager.cash_count = 0
			
			# Updates UI
			GameManager.update_ui_counters()
			
			# Handles fire intensity
			intensity += 30
			if intensity >= 100:
				intensity = 100
			print(intensity)


func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		interact_label.visible = true
		player_in_interaction_range = true


func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		interact_label.visible = false
		player_in_interaction_range = false
