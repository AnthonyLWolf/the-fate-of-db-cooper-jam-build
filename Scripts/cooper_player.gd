extends CharacterBody2D

# References
@onready var item_held: Sprite2D = $ItemHeld
@onready var dialogue_label: Label = $PlayerDialogueLabel
@onready var player_weight_label: Label = $PlayerWeightLabel
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var player_sfx: AudioStreamPlayer2D = $PlayerSFX
@onready var breath_sfx: AudioStreamPlayer2D = $BreathSFX


# Player variables
@export var base_speed = 300.0
@export var daytime_acceleration = 200.0
@export var acceleration = 0.5
@export var jump_velocity = -400.0

var current_weight : int = 0
var carrying_items = false
var holding_item = false
var is_movement_locked = false
var distance_from_home : int = 0
var frozen = false
var dying = false

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
	
	if GameManager.current_state == GameManager.GameState.DAYTIME:
		base_speed += daytime_acceleration

func _physics_process(delta: float) -> void:
	
	if frozen && !dying:
		dying = true
		animated_sprite_2d.play("freeze")
		await get_tree().create_timer(3.0).timeout
		animated_sprite_2d.position += Vector2(0.0,50)
		animated_sprite_2d.play("death")
		# Loads game over screen
		SceneController.load_scene(SceneController.game_over_screen)
		return
	
	# Locks movement
	if is_movement_locked && !frozen:
		player_sfx.stop()
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
		# Handles animation by day phase
		if GameManager.current_state == GameManager.GameState.DAYTIME:
			animated_sprite_2d.play("walk_day")
		elif GameManager.current_state == GameManager.GameState.NIGHTTIME:
			animated_sprite_2d.play("walk_night")
			
		velocity.x = direction * base_speed
		if direction > 0:
			animated_sprite_2d.flip_h = false
			player_weight_label.position = Vector2(-238, -85)
		if direction < 0:
			animated_sprite_2d.flip_h = true
			player_weight_label.position = Vector2(50, -85)
			
		# Handles SFX
		if GameManager.current_state == GameManager.GameState.DAYTIME:
			if !player_sfx.playing:
				player_sfx.stream = AudioManager.player_footstep_hard_sfx
				player_sfx.play(13.1)
			if player_sfx.get_playback_position() >= 17.50:
				player_sfx.seek(13.25)
		if GameManager.current_state == GameManager.GameState.NIGHTTIME:
			if !player_sfx.playing:
				player_sfx.stream = AudioManager.player_foostep_soft_sfx
				player_sfx.play(7.9)
			if player_sfx.get_playback_position() >= 10.71:
				player_sfx.seek(8.0)
	else:
		player_sfx.stop()
		velocity.x = move_toward(velocity.x, 0, base_speed)
		if !frozen: animated_sprite_2d.play("idle")

	move_and_slide()
	
	if carrying_items:
		player_weight_label.text = "Carrying: " + str(inventory["wood"]) + " wood, " + str(inventory["leaves"]) + " dry leaves"
		player_weight_label.visible = true
	elif !carrying_items:
		player_weight_label.visible = false
		
	# Calculate distance from campfire
	calculate_distance(%Campfire)

# Handles different pickups based on the inventory
func pickup_item(fuel_type: String, sender: Node2D):
	if GameManager.current_state == GameManager.GameState.DAYTIME:
		inventory[fuel_type] += 1
		
		# Temporary variable to check weight without affecting actual weight
		var weight_check = (inventory["wood"] * GameConstants.WOOD_WEIGHT) + (inventory["leaves"] * GameConstants.LEAF_WEIGHT)
		
		# Rejects pick-up attempt
		if (weight_check > GameConstants.MAX_PLAYER_WEIGHT):
			inventory[fuel_type] -= 1
			SignalBus.send_dialogue.emit("I'm too heavy. Gotta take some stuff back!")
		# Picks up item
		else:
			# Plays matching sound effect
			if fuel_type == "wood":
				AudioManager.play_sfx(AudioManager.wood_sfx, 0.63)
			elif fuel_type == "leaves":
				AudioManager.play_sfx(AudioManager.leaves_sfx, 0.70)
			
			# Marks player as carrying items and frees the resource from the spawn point
			carrying_items = true
			sender.queue_free()
			
			GameManager.update_ui_counters()
	else:
		return
	
	# Updates current_weight
	current_weight = (inventory["wood"] * GameConstants.WOOD_WEIGHT) + (inventory["leaves"] * GameConstants.LEAF_WEIGHT)

func calculate_distance(home : Node2D):
	var player_position = global_position.x
	var home_position = home.global_position.x
	
	distance_from_home = (home_position - player_position) / 100
	
	if distance_from_home < 0:
		distance_from_home = -distance_from_home
	
	if distance_from_home > 7:
		UiManager.distance_counter_label.visible = true
		UiManager.distance_counter_label.text = "Home: %dm away" % distance_from_home
	else:
		UiManager.distance_counter_label.visible = false

func _display_dialogue(text : String):
	dialogue_label.visible = true
	dialogue_label.text = text
	await get_tree().create_timer(3.0).timeout
	dialogue_label.text = ""
	dialogue_label.visible = false
