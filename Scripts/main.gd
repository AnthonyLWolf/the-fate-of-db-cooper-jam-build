extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	UiManager.hide_all_labels()
	get_tree().change_scene_to_file(SceneController.main_menu_screen)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
