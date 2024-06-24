extends CanvasLayer

@onready var timer_label : Label = %TimerLabel
@onready var kill_label : Label = %KillLabel
@onready var meat_label : Label = %MeatLabel


func _process(delta):
	timer_label.text = GameManager.time_elapsed_string
	meat_label.text = str(GameManager.meat_counter)
	kill_label.text = str(GameManager.monster_defeated_counter)
