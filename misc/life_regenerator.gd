extends Node2D

@onready var meat_collected_sound : AudioStreamPlayer2D = $Area2D/CollisionShape2D/meatcollected

@export var regeration_amount = 20

func _ready():
	$Area2D.body_entered.connect(on_body_entered)

func on_body_entered(body : Node2D) :
	if body.is_in_group("Player"):
		var player : Player = body	
		meat_collected_sound.play()
		player.heal(regeration_amount)
		player.meat_collected.emit(regeration_amount)
		queue_free()
	
