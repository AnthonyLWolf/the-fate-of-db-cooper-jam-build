extends Control

@onready var day_label: Label = $CanvasLayer/Container/VBoxContainer/DayLabel
@onready var phase_label: Label = $CanvasLayer/Container/VBoxContainer/PhaseLabel
@onready var transition_timer: Timer = $TransitionTimer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	phase_label.visible = false
	
	# Handles label text
	day_label.text = "DAY " + str(GameManager.day)
	if GameManager.previous_phase == GameManager.GameState.DAYTIME:
		phase_label.text = "NIGHTTIME"
	if GameManager.previous_phase == GameManager.GameState.NIGHTTIME || GameManager.current_state == GameManager.GameState.GAMESTART:
		phase_label.text = "DAYTIME"
	
	# Allows time for the transition
	AudioManager.play_sfx(AudioManager.fire_on_sfx, 0.0)
	await get_tree().create_timer(0.5).timeout
	transition_timer.start(GameConstants.TRANSITION_LENGTH)
	await get_tree().create_timer(1.0).timeout
	
	phase_label.visible = true
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# IMPORTANT NOTE: THIS IS WHAT STARTS THE GAMEPLAY
func _next_phase() -> void:
	if GameManager.day != GameConstants.MAX_DAYS:
		match GameManager.previous_phase:
			GameManager.GameState.GAMESTART: # Start the game
				GameManager.current_state = GameManager.GameState.DAYTIME
				AudioManager.fade_to_day()
				SceneController.load_scene(SceneController.daytime_scene)
			GameManager.GameState.DAYTIME: # Transition to nighttime logic
				GameManager.current_state = GameManager.GameState.NIGHTTIME
				AudioManager.fade_to_night()
				SceneController.load_scene(SceneController.nighttime_scene)
			GameManager.GameState.NIGHTTIME: # Transition to daytime logic
				GameManager.current_state = GameManager.GameState.DAYTIME
				AudioManager.fade_to_day()
				SceneController.load_scene(SceneController.daytime_scene)


func _on_transition_timer_timeout() -> void:
	_next_phase()
