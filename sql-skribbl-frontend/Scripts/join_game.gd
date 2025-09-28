extends Control

@onready var username_input = $VBoxContainer/Username_input
@onready var rounds_input = $VBoxContainer/Number_of_rounds
@onready var timer_input = $VBoxContainer/Time_per_round_in_seconds

func _ready():
	$VBoxContainer/StartGame.pressed.connect(_on_start_pressed)
	$VBoxContainer/Back.pressed.connect(_on_back_pressed)

func _on_start_pressed():
	Global.username = username_input.text
	Global.num_rounds = rounds_input.value
	Global.round_time = timer_input.value
	print("Joining game as %s, %s rounds, %s seconds" % [Global.username, Global.num_rounds, Global.round_time])
	get_tree().change_scene_to_file("res://scenes/GameScene.tscn")

func _on_back_pressed():
	get_tree().change_scene_to_file("res://Scenes/DifficultyMenu.tscn")
