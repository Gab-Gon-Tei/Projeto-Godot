class_name Enemy
extends Node2D

@export_category("Life")
@export var health : int = 10
@export var death_prefab : PackedScene

@export_category("Drop")
@export var drop_chance : float = 0.1
@export var drop_items : Array [PackedScene]
@export var drop_chances: Array[float]


func damage (amount):
	health -= amount
	#print("O inimigo sofreu", amount, " de dano. A vida total dele é:", health)
	
	#piscar com dano
	modulate = Color.RED
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property(self, "modulate", Color.WHITE, 0.3)

#Processar Morte 
	if health <= 0 :
		die()
		

func die():
	#Caveira
	if death_prefab:
		var death_object = death_prefab.instantiate()
		death_object.position = position
		get_parent().add_child(death_object)
		
		
		#incrmenta um contador
		GameManager.monster_defeated_counter += 1
		#Drop de item
		if randf() <= drop_chance:
			drop_item()
		
		#Deletar node
	queue_free()
	
func drop_item() -> void:
	var drop = get_random_drop_item().instantiate()
	drop.position = position
	get_parent().add_child(drop)
	
func get_random_drop_item() -> PackedScene:	
	
	if drop_items.size() == 1:
		return drop_items [0]
	
	#calcular raridade
	var max_chance : float = 0
	
	for drop_chance in drop_chances:
		max_chance += drop_chance
	
	#sorteio 
	var random_value = randf() * max_chance
	
	#roleta
	var needle : float = 0.0
	for i in drop_items.size():
		var drop_item = drop_items[i]
		var drop_chance = drop_chances[i] if i < drop_chances.size() else 1
		if random_value <= drop_chance + needle:
			return drop_item
		needle += drop_chance	
	return drop_items [0]




