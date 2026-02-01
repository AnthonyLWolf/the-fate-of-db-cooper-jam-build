extends Control

@onready var daytime_counter_label: Label = $CanvasLayer/DayTimeCounter/DaytimeCounterLabel
@onready var cold_bar: TextureProgressBar = %ColdBar
@onready var wood_counter_label: Label = %WoodCounterLabel
@onready var leaf_counter_label: Label = %LeafCounterLabel
@onready var cash_counter_label: Label = %CashCounterLabel
@onready var counters: HBoxContainer = $CanvasLayer/Counters
@onready var distance_counter_label: Label = %DistanceCounterLabel

# Frozen textures
@onready var frozen_texture_1: TextureRect = $CanvasLayer/Control/FrozenTexture1
@onready var frozen_texture_2: TextureRect = $CanvasLayer/Control/FrozenTexture2
@onready var frozen_texture_3: TextureRect = $CanvasLayer/Control/FrozenTexture3

var frozen_textures = []
var labels = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.ui_ready.emit()
	show_daytime_labels()
	
	SignalBus.daytime_start.connect(show_daytime_labels)
	SignalBus.daytime_end.connect(hide_all_labels)
	SignalBus.nighttime_start.connect(show_nighttime_labels)
	SignalBus.nighttime_end.connect(hide_all_labels)
	
	labels = [
		daytime_counter_label,
		cold_bar,
		wood_counter_label,
		leaf_counter_label,
		cash_counter_label
	]
	
	frozen_textures = [
		frozen_texture_1,
		frozen_texture_2,
		frozen_texture_3
	]
	
	
	hide_frozen_textures()
	distance_counter_label.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func show_daytime_labels():
	counters.visible = true
	wood_counter_label.visible = true
	leaf_counter_label.visible = true
	cash_counter_label.visible = true
	daytime_counter_label.visible = true
	cold_bar.visible = false

func hide_all_labels():
	counters.visible = false
	daytime_counter_label.visible = false
	cold_bar.visible = false
	distance_counter_label.visible = false

func hide_frozen_textures():
	for texture in frozen_textures:
		texture.modulate.a = 0.0

func show_nighttime_labels():
	counters.visible = true
	wood_counter_label.visible = true
	leaf_counter_label.visible = true
	cash_counter_label.visible = true
	daytime_counter_label.visible = false
	cold_bar.visible = true
	cold_bar.value = 0.0
