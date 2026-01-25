extends CharacterBody2D

# References
@onready var item_held: Sprite2D = $ItemHeld
@onready var dialogue_label: Label = $PlayerDialogueLabel
@onready var player_weight_label: Label = $PlayerWeightLabel
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

# Player variables
@export var speed = 300.0
@export var acceleration = 0.5
@export var jump_velocity = -400.0

var current_weight : int = 0
var carrying_items = false
var is_movement_locked = false

var inventory = {
	"wood": 0,
	"leaves": 0,
	"cash": 0
}

func _ready() -> void:
	SignalBus.pickup_requested.connect(pickup_item)
	SignalBus.send_dialogue.connect(_display_dialogue)
	item_held.visible = false
	dialogue_label.visible = false

func _physics_process(delta: float) -> void:
	# Locks movement
	if is_movement_locked:
		animated_sprite_2d.play("idle")
		velocity.y += get_gravity().y * delta
		velocity.x = 0
		player_weight_label.visible = false
		move_and_slide()
		return
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * speed
		animated_sprite_2d.play("walk")
		if direction > 0:
			animated_sprite_2d.flip_h = false
			player_weight_label.position = Vector2(-238, -85)
		if direction < 0:
			animated_sprite_2d.flip_h = true
			player_weight_label.position = Vector2(50, -85)
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		animated_sprite_2d.play("idle")

	move_and_slide()
	
	if carrying_items:
		player_weight_label.text = "Carrying: " + str(inventory["wood"]) + " wood, " + str(inventory["leaves"]) + " dry leaves"
		player_weight_label.visible = true
	elif !carrying_items:
		player_weight_label.visible = false

# Handles different pickups based on the inventory
func pickup_item(fuel_type: String, sender: Node2D):
	if GameManager.current_state == GameManager.GameState.DAYTIME:
		inventory[fuel_type] += 1
		
		# Temporary variable to check weight without affecting actual weight
		var weight_check = (inventory["wood"] * GameConstants.WOOD_WEIGHT) + (inventory["leaves"] * GameConstants.LEAF_WEIGHT)
		
		if (weight_check > GameConstants.MAX_PLAYER_WEIGHT):
			inventory[fuel_type] -= 1
			
		else:
			carrying_items = true
			sender.queue_free()
			
			GameManager.update_ui_counters()
	else:
		return
	
	# Updates current_weight
	current_weight = (inventory["wood"] * GameConstants.WOOD_WEIGHT) + (inventory["leaves"] * GameConstants.LEAF_WEIGHT)

func _display_dialogue(text : String):
	dialogue_label.visible = true
	dialogue_label.text = text
	await get_tree().create_timer(3.0).timeout
	dialogue_label.text = ""
	dialogue_label.visible = false
