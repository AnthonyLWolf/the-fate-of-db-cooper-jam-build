extends Node2D

# References
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var interact_label: Label = $Sprite2D/InteractLabel

# Textures for the held item
var log_texture = preload("res://Assets/PlaceholderSprites/Game Jam Placeholder Sprites/logspritePLACEHOLDER.png")
var leaves_texture = null
var cash_texture = null
var tent_texture = preload("res://Assets/PlaceholderSprites/Game Jam Placeholder Sprites/tentspritePLACEHOLDER.png")

# Handles stack type
@export var is_wood = false
@export var is_leaves = false
@export var is_cash = false

var player_in_range = false
var player : Node2D
var stack_count : int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interact_label.visible = false
	player = get_tree().get_nodes_in_group("Player")[0]
	
	SignalBus.cash_burned.connect(update_cash)
	
	if is_wood:
		sprite_2d.texture = log_texture
	elif is_leaves:
		sprite_2d.texture = leaves_texture
	elif is_cash:
		sprite_2d.texture = tent_texture
		stack_count = GameConstants.STARTING_CASH


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	# Daytime behaviour: pick up items
	match GameManager.current_state:
		GameManager.GameState.DAYTIME:
			if Input.is_action_just_pressed("interact") && player_in_range:
				for resource in player.inventory:
					print(player.inventory[resource])
					if player.inventory[resource] > 0:
						for i in player.inventory[resource]:
							add_to_stack(resource)
						GameManager.update_ui_counters()
		# Nighttime behaviour: take from stack
		GameManager.GameState.NIGHTTIME:
			if Input.is_action_just_pressed("interact") && player_in_range:
				# Handles picking up and putting back items if the stack is not empty
				if stack_count > 0:
					if !player.holding_item:
						player.holding_item = true
						if is_wood && GameManager.wood_count > 0:
							player.item_held.texture = log_texture
							player.item_held.visible = true
							player.inventory["wood"] += 1
							stack_count -= 1
						if is_leaves && GameManager.leaf_count > 0:
							player.item_held.texture = leaves_texture
							player.item_held.visible = true
							player.inventory["leaves"] += 1
							stack_count -= 1
						if is_cash && GameManager.cash_count > 0:
							player.item_held.texture = tent_texture
							player.item_held.visible = true
							player.inventory["cash"] += 1
							stack_count -= 1
					# Handles putting back items if they're not used
					else:
						if is_wood && GameManager.wood_count > 0:
							player.item_held.visible = false
							player.inventory["wood"] -= 1
							stack_count += 1
							player.holding_item = false
						if is_leaves && GameManager.leaf_count > 0:
							player.item_held.visible = false
							player.inventory["leaves"] -= 1
							stack_count += 1
							player.holding_item = false
						if is_cash && GameManager.cash_count > 0:
							player.item_held.visible = false
							player.inventory["cash"] -= 1
							player.holding_item = false
				else:
					print("The stack is empty!")

func add_to_stack(fuel_type: String):
	match fuel_type:
		"wood":
			if is_wood:
				player.inventory[fuel_type] -= 1
				stack_count += 1
				GameManager.wood_count += 1
		"leaves":
			if is_leaves:
				player.inventory[fuel_type] -= 1
				stack_count += 1
				GameManager.leaf_count += 1
	await get_tree().create_timer(0.5).timeout
	if player.inventory["wood"] <= 0 && player.inventory["leaves"] <= 0:
		player.carrying_items = false


func update_cash(burned_cash : int):
	if self.is_cash:
		stack_count -= burned_cash
		print(stack_count)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		interact_label.visible = true
		player_in_range = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		interact_label.visible = false
		player_in_range = false
