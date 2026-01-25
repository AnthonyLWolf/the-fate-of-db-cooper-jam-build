extends Node2D

@onready var interact_label: Label = $Control/InteractLabel
@onready var sprite_2d: Sprite2D = $Sprite2D

# Textures
const LEAFRESOURCE = preload("uid://c6g56fsi18a65")
const WOODRESOURCE_1 = preload("uid://cr86omdoj0ia6")
const WOODRESOURCE_2 = preload("uid://bygfp3qa0peuq")
const WOODRESOURCE_3 = preload("uid://xvv548yugg3p")
# TODO: Cash resource

var wood_textures = [
	WOODRESOURCE_1,
	WOODRESOURCE_2,
	WOODRESOURCE_3
]

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
	
	# Assigns random wood texture woop woop
	match current_type:
		"wood":
			var random_texture_index = randi_range(0, wood_textures.size() - 1)
			sprite_2d.texture = wood_textures[random_texture_index]
			sprite_2d.scale = Vector2(0.05, 0.05)
		"leaves":
			sprite_2d.texture = LEAFRESOURCE
			sprite_2d.scale = Vector2(0.05, 0.05)

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
