extends Node2D

@onready var interact_label: Label = $Sprite2D/InteractLabel

var player_in_range = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interact_label.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact") && player_in_range:
		GameManager.wood_count += 1
		GameManager.update_ui_counters()
		queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		interact_label.visible = true
		player_in_range = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		interact_label.visible = false
		player_in_range = false
