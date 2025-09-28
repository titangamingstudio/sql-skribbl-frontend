extends Control

func _ready():
	$VBoxContainer/Multiplayer.pressed.connect(_on_multiplayer_pressed)
	$VBoxContainer/SinglePlayer.pressed.connect(_on_singleplayer_pressed)
	$VBoxContainer/Back.pressed.connect(_on_back_pressed)

func _on_multiplayer_pressed():
	get_tree().change_scene_to_file("res://Scenes/DifficultyMenu.tscn")

func _on_singleplayer_pressed():
	get_tree().change_scene_to_file("res://Scenes/DifficultyMenu.tscn")

func _on_back_pressed():
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
