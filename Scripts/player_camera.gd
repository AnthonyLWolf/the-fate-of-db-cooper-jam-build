extends Camera2D
@onready var soft_snow: GPUParticles2D = $SoftSnow
@onready var blizzard: GPUParticles2D = $Blizzard

var zooming_in : bool
var zooming_out : bool
var player : Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if GameManager.current_state == GameManager.GameState.DAYTIME:
		zoom = Vector2(1.8, 1.8)
	elif GameManager.current_state == GameManager.GameState.NIGHTTIME:
		zoom = Vector2(1.5, 1.5)
	
	check_weather()
	player = get_tree().get_first_node_in_group("Player")
	
	# Zoom-out features
	SignalBus.zoom_out.connect(zoom_out)
	
	# Zoom-in features
	SignalBus.froze_to_death.connect(zoom_in)
	SignalBus.daytime_end.connect(zoom_in)
	SignalBus.nighttime_end.connect(zoom_in)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	

func zoom_in():
	if !zooming_in:
		zooming_in = true
		create_tween().tween_property(self, "zoom", Vector2(2.0, 2.0), 2.5).set_trans(Tween.TRANS_SINE)
		zooming_in = false

func zoom_out():
	if !zooming_out:
		zooming_out = true
		create_tween().tween_property(self, "zoom", Vector2(1.2, 1.2), 1.5).set_trans(Tween.TRANS_SINE)
		zooming_out = false

func check_weather():
		var d = GameManager.day
		
		if d >= 1 && GameManager.current_state == GameManager.GameState.DAYTIME:
			# Soft snow on mornings only
			soft_snow.emitting = true
			blizzard.emitting = false
		elif d < 3 && GameManager.current_state == GameManager.GameState.NIGHTTIME:
			# Soft snow on the first few nights
			soft_snow.emitting = true
			blizzard.emitting = false
		elif d >= 3 && GameManager.current_state == GameManager.GameState.NIGHTTIME:
			# Full storm time!
			soft_snow.emitting = false
			blizzard.emitting = true
		else:
			# Clear weather
			soft_snow.emitting = false
			blizzard.emitting = false
			
