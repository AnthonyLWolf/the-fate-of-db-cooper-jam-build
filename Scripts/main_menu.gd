extends Control

@onready var play_again_button: Button = $CanvasLayer/Control/VBoxContainer/HBoxContainer/PlayAgainButton
@onready var how_to_play_button: Button = $CanvasLayer/Control/VBoxContainer/HBoxContainer/HowToPlayButton
@onready var quit_button: Button = $CanvasLayer/Control/VBoxContainer/HBoxContainer/QuitButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.day = 1
	GameManager.cash_count = GameConstants.STARTING_CASH
	GameManager.current_state = GameManager.GameState.GAMESTART


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_play_again_button_pressed() -> void:
	GameManager.current_state = GameManager.GameState.GAMESTART
	SceneController.load_scene(SceneController.transition_screen)


func _on_how_to_play_button_pressed() -> void:
	pass # Replace with function body.


func _on_quit_button_pressed() -> void:
	get_tree().quit()
