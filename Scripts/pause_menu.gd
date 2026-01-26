extends CanvasLayer

@onready var resume_btn = $CenterContainer/VBoxContainer/PauseContainer/Resume
@onready var vol_slider = $CenterContainer/VBoxContainer/VolContainer/HSlider
@onready var menu_button = $CenterContainer/VBoxContainer/QuitButtonContainer/MenuButton
@onready var quit_btn = $CenterContainer/VBoxContainer/QuitButtonContainer/Quit

func _ready():
	# Hide the menu on start
	visible = false 
	
	# Connect signals
	resume_btn.pressed.connect(_on_resume_pressed)
	quit_btn.pressed.connect(_on_quit_pressed)
	vol_slider.value_changed.connect(_on_volume_changed)
	
	# Set slider to current volume
	var bus_index = AudioServer.get_bus_index("Master")
	vol_slider.value = db_to_linear(AudioServer.get_bus_volume_db(bus_index))

func _input(event):
	if event.is_action_pressed("pause"):
		toggle_pause()

func toggle_pause():
	var is_paused = !get_tree().paused
	get_tree().paused = is_paused # Stops the game logic
	visible = is_paused # Show/Hide the menu
	
	if is_paused:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		# Input.mouse_mode = Input.MOUSE_MODE_CAPTURED 
		pass

func _on_resume_pressed():
	toggle_pause()

func _on_volume_changed(value):
	var bus_index = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))

func _on_menu_button_pressed() -> void:
	toggle_pause()
	GameManager.reset_game()
	AudioManager.stop_all_players()
	GameManager.current_state = GameManager.GameState.GAMESTART
	SceneController.load_scene(SceneController.main_menu_screen)

func _on_quit_pressed():
	get_tree().quit()
