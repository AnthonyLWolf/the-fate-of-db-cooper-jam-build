extends Control

@onready var start_button: Button = $CanvasLayer/Control/VBoxContainer/HBoxContainer/StartButton
@onready var how_to_play_button: Button = $CanvasLayer/Control/VBoxContainer/HBoxContainer/HowToPlayButton
@onready var quit_button: Button = $CanvasLayer/Control/VBoxContainer/HBoxContainer/QuitButton
@onready var how_to_panel: Panel = $CanvasLayer/HiddenMenus/HowToPanel
@onready var credits_panel: Panel = $CanvasLayer/HiddenMenus/CreditsPanel
@onready var hidden_menus: Control = $CanvasLayer/HiddenMenus

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hidden_menus.hide()
	# GameManager.reset_game()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_start_button_pressed() -> void:
	GameManager.current_state = GameManager.GameState.INTRO
	SceneController.load_scene(SceneController.intro_screen)

func _on_how_to_play_button_pressed() -> void:
	hidden_menus.show()
	how_to_panel.show()
	credits_panel.hide()



func _on_how_to_back_button_pressed() -> void:
	how_to_panel.hide()
	credits_panel.hide()
	hidden_menus.hide()


func _on_credits_button_pressed() -> void:
	hidden_menus.show()
	credits_panel.show()
	how_to_panel.hide()


func _on_credits_back_button_pressed() -> void:
	credits_panel.hide()
	how_to_panel.hide()
	hidden_menus.hide()

func _on_quit_button_pressed() -> void:
	get_tree().quit()
