extends Control

@onready var walk : AnimationPlayer =  %Walk
@onready var attack : AnimationPlayer = %Attack
@onready var transition = $Transition/AnimationPlayer


func _ready():
	walk.play("walk")
	attack.play("attack")

func _on_play_pressed():
	transition.play("fade_out")
	get_tree().change_scene_to_file("res://scenes/main.tscn")

	
