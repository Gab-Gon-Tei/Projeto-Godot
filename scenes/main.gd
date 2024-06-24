extends Node

@export var game_ui : CanvasLayer
@export var game_over_ui_template : PackedScene
@onready var transition = $Transition/AnimationPlayer

func _ready():
	transition.play("fade_in")
	GameManager.game_over.connect(trigger_game_over)


func trigger_game_over():
	#Deletar o gameui
	if game_ui:
		game_ui.queue_free()
		game_ui = null
			
	#Criar o gameover
	var game_over_ui: GameOverUI = game_over_ui_template.instantiate()
	add_child(game_over_ui)
