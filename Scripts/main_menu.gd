extends Control

@onready var start_button: Button = $CanvasLayer/Control/VBoxContainer/HBoxContainer/StartButton
@onready var how_to_play_button: Button = $CanvasLayer/Control/VBoxContainer/HBoxContainer/HowToPlayButton
@onready var quit_button: Button = $CanvasLayer/Control/VBoxContainer/HBoxContainer/QuitButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	# GameManager.reset_game()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_start_button_pressed() -> void:
	GameManager.current_state = GameManager.GameState.GAMESTART
	SceneController.load_scene(SceneController.transition_screen)

func _on_how_to_play_button_pressed() -> void:
	pass # Replace with function body.


func _on_quit_button_pressed() -> void:
	get_tree().quit()
