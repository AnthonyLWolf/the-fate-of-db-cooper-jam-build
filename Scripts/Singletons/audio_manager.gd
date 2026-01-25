extends Node2D

# Music tracks
const daytime_track = preload("res://Assets/Audio/Music/MAIN THEME - DAY TIME (loop song).mp3")
const nighttime_track = preload("res://Assets/Audio/Music/NIGHT TIME THEME .mp3")

# Ambient tracks
const fire_night_env = preload("res://Assets/Audio/SFX/ENV/FIRE  NIGHTTIME.mp3")
const fire_forest_day_env = preload("res://Assets/Audio/SFX/ENV/FIRE & FOREST DAYTIME .mp3")
const forest_day_env = preload("res://Assets/Audio/SFX/ENV/FOREST DAY TIME .mp3")
const forest_night_env = preload("res://Assets/Audio/SFX/ENV/FOREST ENV NIGHT TIME.mp3")
const storm_env_env = preload("res://Assets/Audio/SFX/ENV/STORM.mp3")
const wind_env = preload("res://Assets/Audio/SFX/ENV/WIND IN TREES .mp3")
const wolves_howl_env = preload("res://Assets/Audio/SFX/ENV/WOLVES CALLING NIGHT .mp3")

# Gameplay sounds
const game_over_fire_sfx = preload("res://Assets/Audio/SFX/GAMEPLAY SOUND/FIRE OFF (GAME OVER).mp3")
const burn_resource_sfx = preload("res://Assets/Audio/SFX/GAMEPLAY SOUND/FIRE ON.mp3")
const nighttime_transition_sfx = preload("res://Assets/Audio/SFX/GAMEPLAY SOUND/IT_S THE NIGHT TIME SOUND TRANSITION DAY_NIGHT.mp3")
const leaves_sfx = preload("res://Assets/Audio/SFX/GAMEPLAY SOUND/LEAVES.mp3")
const cash_sfx = preload("res://Assets/Audio/SFX/GAMEPLAY SOUND/MONEY.mp3")
const fire_on_sfx = preload("res://Assets/Audio/SFX/GAMEPLAY SOUND/SOUND FIRE ON MAIN MENU(_).mp3")
const wood_sfx = preload("res://Assets/Audio/SFX/GAMEPLAY SOUND/WOOD .mp3")

# Player sounds
const player_cold_breath = preload("res://Assets/Audio/SFX/PLAYER/BREATHING.mp3")
const player_footstep_hard_sfx = preload("res://Assets/Audio/SFX/PLAYER/Footstep HARD (walk_run).mp3")
const player_foostep_soft_sfx = preload("res://Assets/Audio/SFX/PLAYER/Footstep SOFT.mp3")

# References
@onready var daytime_music_player: AudioStreamPlayer = $DaytimeMusicPlayer
@onready var nighttime_music_player: AudioStreamPlayer = $NighttimeMusicPlayer
@onready var root_ambience_player: Node = $AmbiencePlayer
@onready var base_ambience_player: AudioStreamPlayer = $AmbiencePlayer/BaseAmbience
@onready var wind_layer: AudioStreamPlayer = $AmbiencePlayer/WindLayer
@onready var storm_layer: AudioStreamPlayer = $AmbiencePlayer/StormLayer
@onready var wolves_layer: AudioStreamPlayer = $AmbiencePlayer/WolvesLayer
@onready var root_sfx_player: Node = $SFXPlayers


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# Plays any SFX on command. NOTE: ONLY use for short gameplay sounds, not looping!
func play_sfx(stream: AudioStream, start_point : float):
	var sfx_player = AudioStreamPlayer.new()
	root_sfx_player.add_child(sfx_player)
	sfx_player.stream = stream
	sfx_player.bus = AudioServer.get_bus_name(2)
	sfx_player.play(start_point)
	
	sfx_player.finished.connect(sfx_player.queue_free)

func stop_all_players():
	var tween = create_tween().set_parallel(true)
	tween.tween_property(daytime_music_player, "volume_db", -80, 2.0) # Fade out
	tween.tween_property(nighttime_music_player, "volume_db", -80, 2.0) # Fade out
	if base_ambience_player.playing: base_ambience_player.stop()
	if wind_layer.playing: wind_layer.stop()
	if storm_layer.playing: storm_layer.stop()
	if wolves_layer.playing: wolves_layer.stop()
	

func fade_to_night():
	var tween = create_tween().set_parallel(true) # Fade both at once
	tween.tween_property(daytime_music_player, "volume_db", -80, 2.0) # Fade out
	tween.tween_property(nighttime_music_player, "volume_db", 0, 2.0) # Fade in
	await tween.finished.connect(tween.free)
	daytime_music_player.stop()

func fade_to_day():
	var tween = create_tween().set_parallel(true) # Fade both at once
	tween.tween_property(nighttime_music_player, "volume_db", -80, 2.0) # Fade out
	tween.tween_property(daytime_music_player, "volume_db", 0, 2.0) # Fade in
	await tween.finished.connect(tween.free)
	nighttime_music_player.stop()
