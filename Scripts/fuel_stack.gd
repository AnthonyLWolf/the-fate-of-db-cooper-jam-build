extends Node2D

# References
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var interact_label: Label = $InteractLabelContainer/InteractLabel
@onready var stash_label: Label = $StashLabelContainer/StashLabel


# Textures for the stack and held item
const LEAFICON = preload("res://Assets/Sprites/v1.0/resources/v2leaficon.png")
const LEAFSTASH_EMPTY = preload("res://Assets/Sprites/v1.0/resources/V2leaftarp.png")
const LEAFSTASH_MID = preload("res://Assets/Sprites/v1.0/resources/V2leafstashMID.png")
const LEAFSTASH_FULL = preload("res://Assets/Sprites/v1.0/resources/V2leafstashFULL.png")
const WOODPILETARP_EMPTY = preload("res://Assets/Sprites/v1.0/resources/V2woodtarp.png")
const WOODPILETARP_MID = preload("res://Assets/Sprites/v1.0/resources/V2woodpiletarpMID.png")
const WOODPILETARP_FULL = preload("res://Assets/Sprites/v1.0/resources/V2woodpiletarpFULL.png")

const CASH_TENT_EMPTY = preload("res://Assets/Sprites/v1.0/resources/V2tent.png")
const CASH_TENT_LOW = preload("res://Assets/Sprites/v1.0/resources/V2tentLOWCASH.png")
const CASH_TENT_MID = preload("res://Assets/Sprites/v1.0/resources/V2tentMIDCASH.png")
const CASH_TENT_FULL = preload("res://Assets/Sprites/v1.0/resources/V2tentFULLCASH.png")


const LEAFRESOURCE = preload("res://Assets/Sprites/v1.0/resources/V2leafresource.png")
const WOODRESOURCE = preload("res://Assets/Sprites/v1.0/resources/V2woodresource1.png")
const CASHRESOURCE = preload("res://Assets/Sprites/v1.0/resources/V2cashicon.png")

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
		stack_count = GameManager.wood_count
		stash_label.text = "Wood"
	if is_leaves:
		stack_count = GameManager.leaf_count
		stash_label.text = "Leaves"
	if is_cash:
		sprite_2d.texture = CASH_TENT_FULL
		stash_label.visible = false
		stack_count = GameManager.cash_count
		
	check_stash()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	# Daytime behaviour: pick up items
	match GameManager.current_state:
		GameManager.GameState.DAYTIME:
			if Input.is_action_just_pressed("interact") && player_in_range:
				if !player.carrying_items:
					SignalBus.send_dialogue.emit("I'm not carrying anything!")
				else:
					if is_wood:
						if player.inventory["wood"] > 0:
							add_to_stack("wood", player.inventory["wood"])
						elif player.inventory["wood"] <= 0 && player.inventory["leaves"] > 0:
							SignalBus.send_dialogue.emit("This ain't my leaves pile.")
					elif is_leaves:
						if player.inventory["leaves"] > 0:
							add_to_stack("leaves", player.inventory["leaves"])
						elif player.inventory["leaves"] <= 0 && player.inventory["wood"] > 0:
							SignalBus.send_dialogue.emit("This ain't my wood pile.")
					GameManager.update_ui_counters()
		# Nighttime behaviour: take from stack
		GameManager.GameState.NIGHTTIME:
			if Input.is_action_just_pressed("interact") && player_in_range:
				# Handles picking up and putting back items if the stack is not empty
				if stack_count > 0:
					if !player.holding_item:
						if is_wood && GameManager.wood_count > 0:
							player.item_held.texture = WOODRESOURCE
							player.item_held.visible = true
							player.inventory["wood"] += 1
							stack_count -= 1
							AudioManager.play_sfx(AudioManager.wood_sfx, 0.63)
							check_stash()
						if is_leaves && GameManager.leaf_count > 0:
							player.item_held.texture = LEAFICON
							player.item_held.visible = true
							player.inventory["leaves"] += 1
							stack_count -= 1
							AudioManager.play_sfx(AudioManager.leaves_sfx, 0.70)
							check_stash()
						if is_cash && GameManager.cash_count > 0:
							player.item_held.texture = CASHRESOURCE
							player.item_held.visible = true
							player.inventory["cash"] += 1
							# AudioManager.play_sfx(AudioManager.cash_sfx, 0.05)
							check_stash()
						player.holding_item = true
					# Handles putting back items if they're not used
					else:
						if is_wood && GameManager.wood_count > 0 && player.inventory["wood"] > 0:
							player.item_held.visible = false
							player.inventory["wood"] -= 1
							stack_count += 1
							player.holding_item = false
							AudioManager.play_sfx(AudioManager.wood_sfx, 0.63)
						if is_leaves && GameManager.leaf_count > 0 && player.inventory["leaves"] > 0:
							player.item_held.visible = false
							player.inventory["leaves"] -= 1
							stack_count += 1
							player.holding_item = false
							AudioManager.play_sfx(AudioManager.leaves_sfx, 0.70)
						if is_cash && GameManager.cash_count > 0 && player.inventory["cash"] > 0:
							player.item_held.visible = false
							player.inventory["cash"] -= 1
							player.holding_item = false
				else:
					SignalBus.send_dialogue.emit("It's empty!")

func add_to_stack(fuel_type: String, quantity: int):
	match fuel_type:
		"wood":
			if is_wood:
				AudioManager.play_sfx(AudioManager.wood_sfx, 0.63)
				player.inventory["wood"] -= quantity
				stack_count += quantity
				GameManager.wood_count += quantity
				check_stash()
		"leaves":
			if is_leaves:
				AudioManager.play_sfx(AudioManager.leaves_sfx, 0.70)
				player.inventory["leaves"] -= quantity
				stack_count += quantity
				GameManager.leaf_count += quantity
				check_stash()
	
	await get_tree().create_timer(0.5).timeout
	if player.inventory["wood"] <= 0 && player.inventory["leaves"] <= 0:
		player.carrying_items = false


func update_cash(burned_cash : int):
	if self.is_cash:
		stack_count -= burned_cash
		check_stash()

func check_stash():
	if is_wood:
		if stack_count <= 0:
			sprite_2d.texture = WOODPILETARP_EMPTY
		elif stack_count > 0 && stack_count < 5:
			sprite_2d.texture = WOODPILETARP_MID
		elif stack_count >= 5:
			sprite_2d.texture = WOODPILETARP_FULL
	elif is_leaves:
		if stack_count <= 0:
			sprite_2d.texture = LEAFSTASH_EMPTY
		elif stack_count > 0 && stack_count < 5:
			sprite_2d.texture = LEAFSTASH_MID
		elif stack_count >= 5:
			sprite_2d.texture = LEAFSTASH_FULL
	elif is_cash:
		var cash_left = GameManager.cash_count
		if cash_left >= 10000:
			sprite_2d.texture = CASH_TENT_FULL
		elif cash_left < 10000:
			sprite_2d.texture = CASH_TENT_MID
		elif cash_left < 5000:
			sprite_2d.texture = CASH_TENT_LOW
		elif cash_left <= 0:
			sprite_2d.texture = CASH_TENT_EMPTY
		stack_count = cash_left


func check_inventory_emptiness() -> bool:
	if player.inventory["wood"] > 0 || player.inventory["leaves"] > 0:
		return false
	else:
		return true

func _on_area_2d_body_entered(body: Node2D) -> void:
	if GameManager.current_state == GameManager.GameState.DAYTIME && self.is_cash:
		return

	if body.is_in_group("Player"):
		interact_label.visible = true
		player_in_range = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		interact_label.visible = false
		player_in_range = false
