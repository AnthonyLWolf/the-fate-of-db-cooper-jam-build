extends Node2D

# References
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var interact_label: Label = $InteractLabelContainer/InteractLabel
@onready var stash_label: Label = $StashLabelContainer/StashLabel


# Textures for the held item
const LEAFICON = preload("uid://dppwq62j2gkju")
const LEAFSTASH_EMPTY = preload("uid://dkfo1lpo32ia2")
const LEAFSTASH_MID = preload("uid://d0wgokxsdn7fv")
const LEAFSTASH_FULL = preload("uid://c0ccha1agrq2k")
const WOODPILETARP_EMPTY = preload("uid://b1qlc78nvw10y")
const WOODPILETARP_MID = preload("uid://c6c4qgavqrcas")
const WOODPILETARP_FULL = preload("uid://csq4ix2ufs7lh")
# const WOODPILE_MID = preload("uid://0ke2xuwfjdi8")
# const WOODPILE_FULL = preload("uid://dxjp5c44t38sj")

const CASH_TENT_EMPTY = preload("res://Assets/Sprites/Tent-Cash/tent.png")
const CASH_TENT_LOW = preload("res://Assets/Sprites/Tent-Cash/tentLOWCASH.png")
const CASH_TENT_MID = preload("res://Assets/Sprites/Tent-Cash/tentMIDCASH.png")
const CASH_TENT_FULL = preload("res://Assets/Sprites/Tent-Cash/tentFULLCASH.png")


const LEAFRESOURCE = preload("uid://c6g56fsi18a65")
const WOODRESOURCE = preload("uid://cr86omdoj0ia6")
const CASHRESOURCE = preload("res://Assets/Sprites/Tent-Cash/cashicon.png")

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
				for resource in player.inventory:
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
						if is_wood && GameManager.wood_count > 0:
							player.item_held.texture = WOODRESOURCE
							player.item_held.scale = Vector2(0.1, 0.1)
							player.item_held.position += Vector2(0, -5.0)
							player.item_held.visible = true
							player.inventory["wood"] += 1
							stack_count -= 1
							AudioManager.play_sfx(AudioManager.wood_sfx, 0.63)
							check_stash()
						if is_leaves && GameManager.leaf_count > 0:
							player.item_held.texture = LEAFICON
							player.item_held.scale = Vector2(0.1, 0.1)
							player.item_held.position += Vector2(0, -5.0)
							player.item_held.visible = true
							player.inventory["leaves"] += 1
							stack_count -= 1
							AudioManager.play_sfx(AudioManager.leaves_sfx, 0.70)
							check_stash()
						if is_cash && GameManager.cash_count > 0:
							player.item_held.texture = CASHRESOURCE
							player.item_held.scale = Vector2(0.1, 0.1)
							player.item_held.position += Vector2(0, -5.0)
							player.item_held.visible = true
							player.inventory["cash"] += 1
							# AudioManager.play_sfx(AudioManager.cash_sfx, 0.05)
							check_stash()
						player.holding_item = true
					# Handles putting back items if they're not used
					else:
						if is_wood && GameManager.wood_count > 0:
							player.item_held.visible = false
							player.inventory["wood"] -= 1
							stack_count += 1
							player.holding_item = false
							AudioManager.play_sfx(AudioManager.wood_sfx, 0.63)
						if is_leaves && GameManager.leaf_count > 0:
							player.item_held.visible = false
							player.inventory["leaves"] -= 1
							stack_count += 1
							player.holding_item = false
							AudioManager.play_sfx(AudioManager.leaves_sfx, 0.70)
						if is_cash && GameManager.cash_count > 0:
							player.item_held.visible = false
							player.inventory["cash"] -= 1
							player.holding_item = false
				else:
					SignalBus.send_dialogue.emit("It's empty!")

func add_to_stack(fuel_type: String):
	match fuel_type:
		"wood":
			if is_wood:
				AudioManager.play_sfx(AudioManager.wood_sfx, 0.63)
				player.inventory[fuel_type] -= 1
				stack_count += 1
				GameManager.wood_count += 1
				check_stash()
		"leaves":
			if is_leaves:
				AudioManager.play_sfx(AudioManager.leaves_sfx, 0.70)
				player.inventory[fuel_type] -= 1
				stack_count += 1
				GameManager.leaf_count += 1
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
			sprite_2d.scale = Vector2(0.1, 0.1)
		elif stack_count > 0 && stack_count < 5:
			sprite_2d.texture = WOODPILETARP_MID
			sprite_2d.scale = Vector2(0.1, 0.1)
		elif stack_count >= 5:
			sprite_2d.texture = WOODPILETARP_FULL
			sprite_2d.scale = Vector2(0.1, 0.1)
	elif is_leaves:
		if stack_count <= 0:
			sprite_2d.texture = LEAFSTASH_EMPTY
			sprite_2d.scale = Vector2(0.1, 0.1)
		elif stack_count > 0 && stack_count < 5:
			sprite_2d.texture = LEAFSTASH_MID
			sprite_2d.scale = Vector2(0.1, 0.1)
		elif stack_count >= 5:
			sprite_2d.texture = LEAFSTASH_FULL
			sprite_2d.scale = Vector2(0.1, 0.1)
	elif is_cash:
		var cash_left = GameManager.cash_count
		if cash_left >= 10000:
			sprite_2d.texture = CASH_TENT_FULL
			sprite_2d.scale = Vector2(0.1, 0.1)
		elif cash_left < 10000:
			sprite_2d.texture = CASH_TENT_MID
			sprite_2d.scale = Vector2(0.1, 0.1)
		elif cash_left < 5000:
			sprite_2d.texture = CASH_TENT_LOW
			sprite_2d.scale = Vector2(0.1, 0.1)
		elif cash_left <= 0:
			sprite_2d.texture = CASH_TENT_EMPTY
		stack_count = cash_left

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
