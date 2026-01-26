extends Control

@onready var night_tint: CanvasModulate = $TextureRect/NightTint
@onready var end_game_label: Label = $CanvasLayer/Control/VBoxContainer/EndGameLabel
@onready var score_label: Label = $CanvasLayer/Control/VBoxContainer/ScoreLabel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	UiManager.hide_all_labels()
	score_label.hide()
	
	if GameManager.out_of_cash || GameManager.froze_to_death:
		AudioManager.play_sfx(AudioManager.game_over_fire_sfx, 2.6)
		night_tint.visible = true
		
		if GameManager.out_of_cash:
			end_game_label.text = "And so Cooper ran out of cash.\nPerhaps this is how the story ends..."
		if GameManager.froze_to_death:
			end_game_label.text = "And so Cooper froze to death.\nPerhaps this is how the story ends..."
		
	# If player survived, the end screen is a bit brighter
	if GameManager.survived:
		night_tint.visible = false
		end_game_label.text = "Congratulations!\nYou helped Cooper survive the blizzard\nand leave the forest.\nPerhaps this is how the story went."
		score_label.show()
		score_label.text = "You managed to keep: $" + str(GameManager.cash_count)

func _on_play_again_button_pressed() -> void:
	GameManager.reset_game()
	AudioManager.stop_all_players()
	GameManager.current_state = GameManager.GameState.GAMESTART
	SceneController.load_scene(SceneController.transition_screen)


func _on_main_menu_button_pressed() -> void:
	GameManager.reset_game()
	AudioManager.stop_all_players()
	GameManager.current_state = GameManager.GameState.GAMESTART
	SceneController.load_scene(SceneController.main_menu_screen)


func _on_quit_button_pressed() -> void:
	get_tree().quit()
