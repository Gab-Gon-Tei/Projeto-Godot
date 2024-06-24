extends Control

@onready var animation_player : AnimatedSprite2D = $HBoxContainer/Warrior
@onready var start_timer : Timer = $StartTimer
@onready var transition = $Transition/AnimationPlayer
var start_delay : float = 2.0

func _ready():
	start_timer.timeout.connect(_on_start_timer_timeout)

func _on_play_pressed():
	animation_player.play("selected")
	transition.play("fade_out")
	start_timer.start(start_delay)

func _on_start_timer_timeout():
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_controls_pressed():
	get_tree().change_scene_to_file("res://scenes/controls.tscn")
	
