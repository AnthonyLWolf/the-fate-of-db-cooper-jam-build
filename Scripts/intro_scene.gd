extends Control

@onready var text_top: Label = $CanvasLayer/VBoxContainer/Text1
@onready var text_bottom: Label = $CanvasLayer/VBoxContainer/Text2
@onready var text_timer: Timer = $TextTimer
@onready var intro_wind_sfx: AudioStreamPlayer = $IntroWindSFX
@onready var cooper_parachute: AnimatedSprite2D = $CooperParachute

# Intro text variables
var line1_top = "On November 24, 1971, a man hijacked Northwest Orient Airlines Flight 305 flying to Seattle, Washington."
var line2_top = "In exchange for releasing the passengers, he received $200,000 and a parachute."
var line3_bottom = "He opened the aircraft's doors, and jumped out over a remote forest in Southwest Washington."
var line4_top = "He became known as D.B. Cooper.\nNow, his fate is in your hands..."

# Timer variables
@export var text_time : float = 2.0
@export var fly_in_time : float = 10.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	# Sets up scene
	cooper_parachute.hide()
	text_top.text = ""
	text_bottom.text = ""
	text_top.hide()
	text_bottom.hide()
	text_timer.wait_time = text_time
	
	# Starts cutscene once ready
	
	start_intro_cutscene()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func start_intro_cutscene():
	await fade_text(line1_top, true)
	await fade_text(line2_top, true)
	fly_in_cooper()
	await fade_text(line3_bottom, false)
	await fade_text(line4_top, true)
	
	# Starts the game
	GameManager.current_state = GameManager.GameState.GAMESTART
	SceneController.load_scene(SceneController.transition_screen)
	
func fade_text(text : String, top : bool):
	if top:
		if text_bottom.visible:
			text_bottom.hide()
		text_top.text = text
		var tween = create_tween()
		text_top.show()
		
		tween.tween_property(text_top, "modulate:a", 1.0, text_time).from(0.0)
		tween.tween_interval(text_time)
		tween.tween_property(text_top, "modulate:a", 0.0, text_time).from(1.0)
		
		await tween.finished
		text_top.hide()
	elif !top:
		if text_top.visible:
			text_top.hide()
		text_bottom.text = text
		var tween = create_tween()
		text_bottom.show()
		
		tween.tween_property(text_bottom, "modulate:a", 1.0, text_time).from(0.0)
		tween.tween_interval(text_time)
		tween.tween_property(text_bottom, "modulate:a", 0.0, text_time).from(1.0)
		
		await tween.finished
		text_bottom.hide()

func fly_in_cooper():
	# Prepares fly-in animation
	var origin_pos = cooper_parachute.global_position
	var target_pos = Vector2(2112.0, 586.0)
	cooper_parachute.show()
	cooper_parachute.global_position = origin_pos
	
	# Animates fly-in
	var tween = create_tween()
	tween.tween_property(cooper_parachute, "global_position", target_pos, fly_in_time).from(origin_pos)
	await tween.finished
	cooper_parachute.hide()


func _on_skip_button_pressed() -> void:
	GameManager.current_state = GameManager.GameState.GAMESTART
	SceneController.load_scene(SceneController.transition_screen)


func _on_text_timer_timeout() -> void:
	pass # Replace with function body.
