extends CharacterBody2D

# References
@onready var item_held: Sprite2D = $ItemHeld
@onready var dialogue_label: Label = $PlayerDialogueLabel

# Player variables
@export var speed = 300.0
@export var acceleration = 0.5
@export var jump_velocity = -400.0

var current_weight : int = 0
var holding_item = false
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
		velocity.y += get_gravity().y * delta
		velocity.x = 0
		move_and_slide()
		return
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("confirm") and is_on_floor():
		velocity.y = jump_velocity

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()

# Handles different pickups based on the inventory
func pickup_item(fuel_type: String, sender: Node2D):
	# TODO: IF DAYTIME!!!
	inventory[fuel_type] += 1
	
	# Temporary variable to check weight without affecting actual weight
	var weight_check = (inventory["wood"] * GameConstants.WOOD_WEIGHT) + (inventory["leaves"] * GameConstants.LEAF_WEIGHT)
	
	if (weight_check > GameConstants.MAX_PLAYER_WEIGHT):
		inventory[fuel_type] -= 1
		print("You're too heavy! Deposit some items to pick this up")
	else:
		print("You've picked up " + fuel_type + "!")
		sender.queue_free()
		
		match fuel_type:
			"wood":
				pass # TODO: Something that adds to current inventory
			"leaves":
				pass # TODO: Something that adds to current inventory
		
		GameManager.update_ui_counters()
		
	
	# Updates current_weight
	current_weight = (inventory["wood"] * GameConstants.WOOD_WEIGHT) + (inventory["leaves"] * GameConstants.LEAF_WEIGHT)
	print(current_weight)

func _display_dialogue(text : String):
	dialogue_label.visible = true
	dialogue_label.text = text
	await get_tree().create_timer(3.0).timeout
	dialogue_label.text = ""
	dialogue_label.visible = false
