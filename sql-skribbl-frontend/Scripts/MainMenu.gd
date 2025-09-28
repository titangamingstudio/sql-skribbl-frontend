extends Control

func _ready():
	$VBoxContainer/Play.pressed.connect(_on_play_pressed)
	$VBoxContainer/Learn.pressed.connect(_on_learn_pressed)
	$VBoxContainer/Leaderboards.pressed.connect(_on_leaderboard_pressed)
	$VBoxContainer/Sound.pressed.connect(_on_sound_pressed)

func _on_play_pressed():
	get_tree().change_scene_to_file("res://Scenes/PlayMenu.tscn")

func _on_learn_pressed():
	get_tree().change_scene_to_file("res://Scenes/LearnMenu.tscn")

func _on_leaderboard_pressed():
	get_tree().change_scene_to_file("res://Scenes/Leaderboard.tscn")

func _on_sound_pressed():
	# TODO: toggle audio mute later
	print("Sound toggle")
