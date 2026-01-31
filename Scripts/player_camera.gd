extends Camera2D
@onready var soft_snow: GPUParticles2D = $SoftSnow
@onready var blizzard: GPUParticles2D = $Blizzard


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	check_weather()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	

func check_weather():
		var d = GameManager.day
		
		if d >= 3 && GameManager.current_state == GameManager.GameState.NIGHTTIME:
			# Full storm time!
			soft_snow.emitting = false
			blizzard.emitting = true
		elif d < 3 && GameManager.current_state == GameManager.GameState.NIGHTTIME:
			# Soft snow on the first few nights
			soft_snow.emitting = true
			blizzard.emitting = false
		elif d >= 1 && GameManager.current_state == GameManager.GameState.DAYTIME:
			# Soft snow on mornings only
			soft_snow.emitting = true
			blizzard.emitting = false
		else:
			# Clear weather
			soft_snow.emitting = false
			blizzard.emitting = false
			
