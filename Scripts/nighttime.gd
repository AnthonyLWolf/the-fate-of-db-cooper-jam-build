extends Node2D

# References
@onready var night_time_timer: Timer = $NightTimeTimer
var player : Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_nighttime_setup()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _nighttime_setup():
	# Handles music
	if AudioManager.nighttime_music_player.playing:
		AudioManager.nighttime_music_player.stop()
	
	if !AudioManager.nighttime_music_player.playing:
		AudioManager.nighttime_music_player.stream = AudioManager.nighttime_track
		AudioManager.nighttime_music_player.play()
	
	play_ambience_sfx()
	
	player = get_tree().get_first_node_in_group("Player")
	
	night_time_timer.start(GameConstants.NIGHTTIME_LENGTH)

func play_ambience_sfx():
	if AudioManager.base_ambience_player.playing:
		AudioManager.base_ambience_player.stop()
	
	AudioManager.base_ambience_player.stream = AudioManager.forest_night_env
	AudioManager.base_ambience_player.play()
	
	if GameManager.day >= 2:
		AudioManager.wind_layer.stop()
		AudioManager.wind_layer.play()
	if GameManager.day >= 4:
		AudioManager.storm_layer.stop()
		AudioManager.storm_layer.play()
	if GameManager.day >= 6:
		AudioManager.wolves_layer.stop()
		AudioManager.wolves_layer.play()


func _on_night_time_timer_timeout() -> void:
	SignalBus.nighttime_end.emit()
	if GameManager.day != GameConstants.MAX_DAYS:
		player.is_movement_locked = true
		SignalBus.transition.emit()
		var night_end_dialogue = "Dawn's breaking. I should get more fuel."
		SignalBus.send_dialogue.emit(night_end_dialogue)
		await get_tree().create_timer(3.0).timeout
		AudioManager.stop_all_players()
		SceneController.load_scene(SceneController.transition_screen)
	else:
		return
	
