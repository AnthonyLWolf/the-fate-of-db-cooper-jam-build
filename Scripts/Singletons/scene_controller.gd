extends Node

@onready var fade_rect: ColorRect = $CanvasLayer/ColorRect

# Scene references
var daytime_scene = "res://Scenes/Game/daytime.tscn"
var nighttime_scene = "res://Scenes/Game/nighttime.tscn"
var transition_screen = "res://Scenes/UI/transition_screen.tscn"

func _ready() -> void:
	pass

func load_scene(target_path : String):
	# Fade to black
	var tween = create_tween()
	tween.tween_property(fade_rect, "color:a", 1.0, 0.5)
	await tween.finished
	
	# Change scene
	get_tree().change_scene_to_file(target_path)
	await get_tree().create_timer(0.1).timeout
	
	# Fade back in
	var tween_in = create_tween()
	tween_in.tween_property(fade_rect, "color:a", 0.0, 0.5)
