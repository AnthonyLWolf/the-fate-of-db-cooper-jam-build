extends Node2D

# References
@onready var interact_label: Label = $Control/InteractLabel
@onready var warmth_shape: CircleShape2D = $WarmthArea/CollisionShape2D.shape
@onready var flame_sprite: AnimatedSprite2D = $FlameSprite
@onready var base_sprite: AnimatedSprite2D = $BaseSprite
@onready var campfire_sfx_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

# Textures
var campfire_base_texture = preload("res://Assets/Sprites/Campfire/DBfireBASE.png")
var campfire_ash_texture = preload("res://Assets/Sprites/Campfire/DBash.png")


# Variables

# Warmth variables
var warmth_decay_rate = 10.0
var intensity_ratio = 0.5
var base_flame_scale : Vector2
var fire_intensity : float = GameConstants.MAX_WARMTH_RADIUS / 2

# Cold variables
var cold_amount : float = 25.0
var cold_decay_rate : float = 5.0
var cold_multiplier : float = min((float(GameManager.day) * cold_decay_rate), 40.0)

var player : Node2D
var player_in_interaction_range = false
var player_in_warmth_range = false
var player_freezing = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interact_label.visible = false
	player = get_tree().get_nodes_in_group("Player")[0]
	base_flame_scale = flame_sprite.scale
	SignalBus.ui_ready.connect(func(): UiManager.cold_bar.value = cold_amount)
	
	# TEST
	#GameManager.current_state = GameManager.GameState.NIGHTTIME


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	match GameManager.current_state:
		# Daytime behaviour: animated differently
		GameManager.GameState.DAYTIME:
			base_sprite.play("daytimeash")
			flame_sprite.visible = false
			
		# Nighttime behaviour: campfire on, ability to burn
		GameManager.GameState.NIGHTTIME:
			
			base_sprite.play("base")
			flame_sprite.visible = true
			flame_sprite.play("idle")
			
			# Plays campfire SFX spatially
			if campfire_sfx_player.playing:
				campfire_sfx_player.stop()
			campfire_sfx_player.play()
			
			UiManager.cold_bar.value = cold_amount
			
			# Checks if player is freezing to death and plays sound if so
			if cold_amount >= 75 && !player_freezing:
				player_freezing = true
				player.breath_sfx.stream = AudioManager.player_cold_breath
				player.breath_sfx.play(0.2)
			
			# Instantly checks if cold amount warrants a game over each frame
			if cold_amount >= GameConstants.MAX_COLD_AMOUNT && !player.frozen:
				player.frozen = true
				player.breath_sfx.stop()
				SignalBus.froze_to_death.emit()
				base_sprite.play("smoulder")
				return
			
			if player.frozen:
				fire_intensity -= warmth_decay_rate
			
			# Animates shape radius based on fire intensity
			intensity_ratio = fire_intensity / GameConstants.MAX_WARMTH_RADIUS
			fire_intensity -= warmth_decay_rate * delta
			# Shrinks sprite based on fire intensity
			flame_sprite.scale = (base_flame_scale * max(intensity_ratio, 0.1)) * 2
			if flame_sprite.scale.x < 0 || flame_sprite.scale.y < 0:
				flame_sprite.scale = Vector2(0,0)
				
			
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
			if player_in_warmth_range:
				cold_amount -= (cold_multiplier / 2) * delta
				
			# Handles burning of fuel
			if Input.is_action_just_pressed("interact") && player_in_interaction_range && player.holding_item:
				
				if GameManager.wood_count > 0 || GameManager.leaf_count > 0 || GameManager.cash_count > 0:
					if fire_intensity < GameConstants.MAX_WARMTH_RADIUS:
						for resource in player.inventory:
							if player.inventory[resource] > 0:
								player.inventory[resource] -= 1
								burn_fuel(resource)


func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") && GameManager.current_state == GameManager.GameState.NIGHTTIME:
		interact_label.visible = true
		player_in_interaction_range = true


func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player") && GameManager.current_state == GameManager.GameState.NIGHTTIME:
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
	
	AudioManager.play_sfx(AudioManager.burn_resource_sfx, 0.0)
	
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
