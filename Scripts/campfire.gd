extends Node2D

# References
@onready var interact_label: Label = $Control/InteractLabel
@onready var warmth_area: Area2D = $WarmthArea
@onready var warmth_shape: CircleShape2D = $WarmthArea/CollisionShape2D.shape
@onready var flame_sprite: AnimatedSprite2D = $FlameSprite
@onready var base_sprite: AnimatedSprite2D = $BaseSprite
@onready var campfire_sfx_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var camplight_outer: PointLight2D = $CampLightOuter
@onready var camplight_inner: PointLight2D = $CampLightInner
var night_time_timer : Timer

# Textures
var campfire_base_texture = preload("res://Assets/Sprites/v1.0/campfire/V2DBfireBASE.png")
var campfire_ash_texture = preload("res://Assets/Sprites/v1.0/campfire/V2DBash.png")


## Variables

# Fuel variables
@export var wood_fuel_power : int
@export var leaves_fuel_power : int
@export var cash_fuel_power : int

# Warmth variables
@export var warmth_decay_rate = 10.0
@export var intensity_ratio = 0.5
var base_flame_scale : Vector2
var fire_intensity : float = GameConstants.MAX_WARMTH_RADIUS / 2

# Cold variables
var warmth_amount : float = 50.0
@export var cold_decay_rate : float = 5.0
var cold_multiplier : float = min((float(GameManager.day) * cold_decay_rate), 40.0)

# Cold texture variables
var frozen_t_1
var frozen_t_2
var frozen_t_3

var player : Node2D
var player_in_interaction_range = false
var player_in_warmth_range = false
var player_freezing = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interact_label.visible = false
	player = get_tree().get_nodes_in_group("Player")[0]
	base_flame_scale = flame_sprite.scale
	
	# Grabs transparency values of frozen textures for opacity modulation, then resets it on ready
	frozen_t_1 = UiManager.frozen_texture_1
	frozen_t_2 = UiManager.frozen_texture_2
	frozen_t_3 = UiManager.frozen_texture_3
	
	frozen_t_1.modulate.a = 0.0
	frozen_t_2.modulate.a = 0.0
	frozen_t_3.modulate.a = 0.0
	
	SignalBus.ui_ready.connect(func(): UiManager.cold_bar.value = warmth_amount)
	
	if GameManager.current_state == GameManager.GameState.NIGHTTIME:
		night_time_timer = $"../NightTimeTimer"
	
	# TESTING FEATURES
	#GameManager.current_state = GameManager.GameState.NIGHTTIME
	#GameManager.day = 4
	#UiManager.daytime_counter_label.show()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	# TEST - DEBUG ONLY
	# UiManager.daytime_counter_label.text = str(round(night_time_timer.time_left))
	
	match GameManager.current_state:
		# Daytime behaviour: animated differently
		GameManager.GameState.DAYTIME:
			camplight_outer.visible = false
			camplight_inner.visible = false
			base_sprite.play("daytimeash")
			flame_sprite.visible = false
			
		# Nighttime behaviour: campfire on, ability to burn
		GameManager.GameState.NIGHTTIME:
			# Turns on the flame
			base_sprite.play("base")
			flame_sprite.visible = true
			flame_sprite.play("idle")
			
			# Animates campfire light
			var flicker = randf_range(-0.05, 0.05)
			camplight_outer.energy = (intensity_ratio + flicker) * 1.5
			
			var light_scale_target = intensity_ratio * 0.5
			camplight_inner.texture_scale = max(light_scale_target, 1.3)
			camplight_inner.energy = intensity_ratio * 2.0
			
			# Plays campfire SFX spatially
			if !campfire_sfx_player.playing:
				campfire_sfx_player.play()
			
			UiManager.cold_bar.value = warmth_amount # TODO: Replace with thermometer
			
			# Activates and modulates textures
			frozen_t_1.modulate.a = remap(warmth_amount, 75.0, 50.0, 0.0, 0.2)
			frozen_t_2.modulate.a = remap(warmth_amount, 50.0, 25.0, 0.0, 0.2)
			frozen_t_3.modulate.a = remap(warmth_amount, 25.0, 0.0, 0.0, 1.0)
			
			# Checks if player is freezing to death and plays sound if so
			if warmth_amount <= 25 && !player_freezing:
				player_freezing = true
				player.breath_sfx.stream = AudioManager.player_cold_breath
				player.breath_sfx.play(0.2)
			else:
				if player.breath_sfx.playing:
					player.breath_sfx.stop()
			
			# Instantly checks if cold amount warrants a game over each frame
			if warmth_amount <= GameConstants.MIN_WARMTH_AMOUNT && !player.frozen:
				player.frozen = true
				player.breath_sfx.stop()
				night_time_timer.stop()
				SignalBus.froze_to_death.emit()
				#TODO: Add optimised texture -> base_sprite.play("smoulder")
				base_sprite.play("base")
				return
			
			if player.frozen:
				fire_intensity = 0
			
			# Animates shape radius based on fire intensity
			intensity_ratio = fire_intensity / GameConstants.MAX_WARMTH_RADIUS
			fire_intensity -= warmth_decay_rate * delta
			# Shrinks sprite based on fire intensity
			flame_sprite.scale = (base_flame_scale * max(intensity_ratio, 0.01)) * 2
				
			
			# Failsafe clamp for fire intensity
			if fire_intensity < GameConstants.MIN_WARMTH_RADIUS:
				fire_intensity = GameConstants.MIN_WARMTH_RADIUS
			if fire_intensity > GameConstants.MAX_WARMTH_RADIUS:
				fire_intensity = GameConstants.MAX_WARMTH_RADIUS 
			
			var target_radius = lerp(GameConstants.MIN_WARMTH_RADIUS, GameConstants.MAX_WARMTH_RADIUS, intensity_ratio)
			warmth_shape.radius = target_radius
			
			# Disables collision on warmth shape to let player freeze when fire is at 0
			if warmth_shape.radius <= 0:
				warmth_area.collision_mask = 10
				flame_sprite.scale = Vector2(0,0)
				if campfire_sfx_player.playing:
					campfire_sfx_player.stop()
			else:
				warmth_area.collision_mask = 1
			
			# Cold mechanic
			if !player_in_warmth_range:
				warmth_amount -= cold_multiplier * delta
			if player_in_warmth_range:
				warmth_amount += (cold_multiplier / 2) * intensity_ratio * delta
			
			# Clamping cold
			if warmth_amount < 0:
				warmth_amount = 0
			elif warmth_amount > 100:
				warmth_amount = 100
				
			# Handles burning of fuel
			if Input.is_action_just_pressed("interact") && player_in_interaction_range && player.holding_item:
				
				if GameManager.wood_count > 0 || GameManager.leaf_count > 0 || GameManager.cash_count > 0:
					if fire_intensity < GameConstants.MAX_WARMTH_RADIUS:
						for resource in player.inventory:
							if player.inventory[resource] > 0:
								player.inventory[resource] -= 1
								burn_fuel(resource)


func burn_fuel(fuel_type : String):
	player.item_held.visible = false
	match fuel_type:
		"wood":
			fire_intensity += wood_fuel_power
			GameManager.wood_count -= 1
		"leaves":
			fire_intensity += leaves_fuel_power
			GameManager.leaf_count -= 1
		"cash":
			fire_intensity += cash_fuel_power
			var cash_to_burn = randi_range(10000, 30000)
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

func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") && GameManager.current_state == GameManager.GameState.NIGHTTIME:
		interact_label.visible = true
		player_in_interaction_range = true


func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player") && GameManager.current_state == GameManager.GameState.NIGHTTIME:
		interact_label.visible = false
		player_in_interaction_range = false


func _on_warmth_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_warmth_range = true


func _on_warmth_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_warmth_range = false
