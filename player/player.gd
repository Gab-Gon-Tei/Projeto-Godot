class_name Player
extends CharacterBody2D


#Variáveis exportáveis
@export_category("Velocidade")
@export var speed : float = 3
@export_range(0,1) var control_lerp  = 1.0

@export_category("Sword")
@export var sword_damage = 4

@export_category("Vida")
@export var health : int = 100
@export var max_health : int = 100
@export var death_prefab : PackedScene

@export_category("Ritual")
@export var ritual_damage : int = 10
@export var ritual_interval : float = 30
@export var ritual_scene : PackedScene

#Trás elemntos ao script
@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var sprite : Sprite2D = $Sprite2D
@onready var sword_area : Area2D = $SwordArea
@onready var hitbox_area : Area2D = $HitboxArea
@onready var health_progress_bar : ProgressBar = $HealthProgressBar
@onready var slash_sound : AudioStreamPlayer2D = $slash



signal meat_collected(value:int)

func _ready():
	GameManager.player = self
	meat_collected.connect(func(value:int): GameManager.meat_counter += 1)
	
#Variável para verificar se o personagem está em movimento
var is_running : bool = false
#Variável para verificar se o personagem está atacando
var is_attacking : bool = false 

#temporizadores
var atk_cooldown : float = 0.0
var hitbox_cooldown : float = 0.0
var ritual_cooldown: float = 0.0

# Direção do ataque
var attack_direction : Vector2 = Vector2.ZERO

func _process(delta) -> void:
	if atk_cooldown > 0 :
		atk_cooldown -= delta
		if atk_cooldown <= 0.0:
			is_attacking = false
			is_running = false
			animation_player.play("idle")
	
	update_hitbox_area(delta)
	
	update_ritual(delta)
	
	#Update da barra de progresso
	health_progress_bar.max_value = max_health
	health_progress_bar.value = health
		

#movimentação do personagem e física
func _physics_process(delta):
	
	GameManager.player_position = position
	
	var input_vector = Input.get_vector("move_left","move_right","move_up","move_down")
	var target_velocity = input_vector * speed * 100.0
	if is_attacking: 
		velocity *= 0.25
	velocity = lerp(velocity, target_velocity, control_lerp)
	move_and_slide()
	
	#atualização do is_running
	var was_running = is_running
	is_running = not input_vector.is_zero_approx()
	
	#Tocar animação
	if not is_attacking:
		if was_running != is_running:
			if is_running :
				animation_player.play("run")
			else :
				animation_player.play("idle")
	
	#Girar sprite
	if not is_attacking:
		if input_vector.x > 0:
			#desmarcar o flip H
			sprite.flip_h = false
			
		elif input_vector.x < 0:
			sprite.flip_h = true
		

	if Input.is_action_just_pressed("attack"):
		attack(input_vector)
		slash_sound.play()
		
	
func attack(input_vector: Vector2) -> void :
	if is_attacking:
		return
# Direção do ataque
	attack_direction = input_vector
	if attack_direction == Vector2.ZERO:
		# Caso o jogador não esteja movendo, atacar na direção atual		
		if sprite.flip_h:
			attack_direction = Vector2.LEFT
		else:
			attack_direction = Vector2.RIGHT

	# Direcionando o ataque
	var prev_velocity = velocity
	var attack_animation = "attack"
	
	if attack_direction.y < 0:
		attack_animation = "attack_up"
	elif attack_direction.y > 0:
		attack_animation = "attack_backdown"
	
	animation_player.play(attack_animation)	
	velocity = prev_velocity
		
	atk_cooldown = 0.6
	is_attacking = true
		
func deal_damage_to_enemies(input_vector : Vector2):
	var bodies = sword_area.get_overlapping_bodies()
	for body in bodies :
		if body.is_in_group("enemies") :
			var enemy : Enemy = body
			
			var direction_to_enemy = (enemy.position - position).normalized()
						
			var dot_product = direction_to_enemy.dot(attack_direction)
		
			
			# Se o inimigo estiver na direção do ataque, aplicar dano
			if dot_product > 0.3: 
				enemy.damage(sword_damage)
						
func update_hitbox_area(delta):
	#Temporizador 
	hitbox_cooldown -= delta
	if hitbox_cooldown > 0 : return
	
	#Frequencia de dano
	hitbox_cooldown = 0.5
	
	#processa o hitboxarea
	var bodies = hitbox_area.get_overlapping_bodies()
	for body in bodies :
		if body.is_in_group("enemies") :
			var enemy : Enemy = body
			var damage_amount = 1
			damage(damage_amount)

func update_ritual (delta): 
	ritual_cooldown -= delta
	if ritual_cooldown > 0 : return
	ritual_cooldown = ritual_interval
	
	var ritual = ritual_scene.instantiate()
	ritual.damage_amount = ritual_damage
	add_child(ritual)
	
func damage (amount):
	if health <=0 :return
	
	health -= amount
	#print("O herói sofreu", amount, " de dano. A vida total dele é:", health,"/",max_health)
	
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
	if death_prefab:
		var death_object = death_prefab.instantiate()
		death_object.position = position
		get_parent().add_child(death_object)		
	queue_free()
	
	GameManager.end_game()
	
func heal(amount):
	health += amount
	if health > max_health:
		health = max_health
		#print("O herói sofreu", amount, " de dano. A vida total dele é:", health,"/",max_health)
	return health
	


