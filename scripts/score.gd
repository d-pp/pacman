extends Node2D

var _score : int = 0
onready var _label = $RichTextLabel

func _ready() -> void:
	change_to(_score)

func change_to(new_score : int):
	_score = new_score
	_label.text = str(_score)

func add(s : int):
	change_to(_score + s)

func sub(s : int):
	change_to(_score - s)
