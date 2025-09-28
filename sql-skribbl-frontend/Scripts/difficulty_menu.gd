extends Control
var chosen_difficulty = ""

func _ready():
	$VBoxContainer/Beginner.pressed.connect(func(): _select_difficulty("beginner"))
	$VBoxContainer/Intermediate.pressed.connect(func(): _select_difficulty("intermediate"))
	$VBoxContainer/Advanced.pressed.connect(func(): _select_difficulty("advanced"))
	$VBoxContainer/Back.pressed.connect(_on_back_pressed)

func _select_difficulty(diff: String):
	chosen_difficulty = diff
	# Store difficulty in autoload (global state)
	Global.selected_difficulty = diff
	get_tree().change_scene_to_file("res://Scenes/JoinGame.tscn")

func _on_back_pressed():
	get_tree().change_scene_to_file("res://Scenes/PlayMenu.tscn")
