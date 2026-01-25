extends Control

@onready var day_label: Label = $CanvasLayer/Container/VBoxContainer/DayLabel
@onready var phase_label: Label = $CanvasLayer/Container/VBoxContainer/PhaseLabel
@onready var transition_timer: Timer = $TransitionTimer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	phase_label.visible = false
	
	day_label.text = "DAY " + str(GameManager.day)
	phase_label.text = str(GameManager.GameState.keys()[GameManager.current_state])
	
	await get_tree().create_timer(0.5).timeout
	transition_timer.start(GameConstants.TRANSITION_LENGTH)
	await get_tree().create_timer(1.0).timeout
	
	phase_label.visible = true
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _next_phase() -> void:
	if GameManager.current_state == GameManager.GameState.DAYTIME:
		SceneController.load_scene(SceneController.nighttime_scene)
		GameManager.current_state = GameManager.GameState.NIGHTTIME
	elif GameManager.current_state == GameManager.GameState.NIGHTTIME:
		SceneController.load_scene(SceneController.daytime_scene)
		GameManager.current_state = GameManager.GameState.DAYTIME


func _on_transition_timer_timeout() -> void:
	_next_phase()
