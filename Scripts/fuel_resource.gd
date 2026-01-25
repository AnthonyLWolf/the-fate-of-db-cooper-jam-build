extends Node2D

@onready var interact_label: Label = $Sprite2D/InteractLabel

var player_in_range = false
var picked_up = false
var current_type : String

var types = [
	"wood",
	"leaves",
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interact_label.visible = false
	current_type = types.pick_random()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact") && player_in_range:
		SignalBus.pickup_requested.emit(current_type, self)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		interact_label.visible = true
		player_in_range = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		interact_label.visible = false
		player_in_range = false
