extends Node2D

@onready var local_raycast: RayCast2D = $RayCast2D
@onready var local_raycast2: RayCast2D = $RayCast2D2

var moving_state := 0
var states_num = [-1,1]
var parent = null
var character = null
var animator = null
var spr_frames = null
var detection_area = null

var entries := []
var entries_names := []
var entries_loops := []

var proceed := true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# O que cada um faz aqui:
	
	parent = get_parent()
	# Pega o objeto pai pra usá-lo depois
	
	character = parent.anim_system
	# Ele vai pegar o sistema automático de animações, em que é um
	# CharacterBody2D (basicamente tudo o que iremos manipular)
	
	animator = character.obj_anim 
	# Pega o AnimatedSprite2D pra usarmos com o objetivo de tocar alguma
	# animação ou afins
	
	spr_frames = animator.sprite_frames
	# Referencia os próprios sprite frames o AS2D, mas não precisa tocar
	# aqui
	
	detection_area = character.detect_collisions
	# Feito pra obter o objeto de Area2D, é uma 2° colisão dentro do
	# inimigo para detectar coisas mesclando com ele, é aqui que
	# pego as 2° funções principais de colisão (Com Corpos e outras Áreas)
	
	# Esses 2 códigos abaixo criam uma conexão entre o sinal de
	# colisão da Area2D pertencente ao sistema de animação.
	detection_area.body_entered.connect(body_collision)
	detection_area.area_entered.connect(area_collision)
	
	# Esse já é feito pra se conectar a um sinal de animação
	animator.animation_finished.connect(_on_animation_finished)

	# Aleatoriamente vai escolher se começa movendo pela esquerda
	# ou pela direita
	moving_state = states_num[randi() % states_num.size()]
	
	# Armazena todas as entries de animação, me julgue pelo meus métodos,
	# mas não pelos  resultados.
	entries = [character.anim_entry0,character.anim_entry1,character.anim_entry2,
	character.anim_entry3,character.anim_entry4,character.anim_entry5,character.anim_entry6,
	character.anim_entry7,character.anim_entry8,character.anim_entry9]
	
	entries_names = []
	entries_loops = []
	
	for i in entries.size():
		if entries[i] != null:
			entries_names.append(entries[i].get_animation_names()[0])
			entries_loops.append(entries[i].get_animation_loop(entries_names[i]))
	
	# Coloca o tamanho do Raycast para ficar de acordo com a hitbox
	# do objeto e multiplica ele só um tantinho (é preciso que ele seja maior)
	local_raycast.target_position.x = character.collision_width * 1.1
	local_raycast2.target_position.y = character.collision_width * 1.1
	
	parent_to_body()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if not character.is_on_floor():
		character.velocity.y += parent.gravity * delta
		
	if moving_state != 0 and parent.generic_health != 0:
		character.velocity.x = moving_state * parent.generic_speed
		animator.scale.x = moving_state
		local_raycast.scale.x = moving_state
		local_raycast2.scale.x = moving_state
		
		# Esse código é importante notar, é assim que você faz uma I.A
		# tocar qualquer tipo de animação. O tipo é aqueles que você coloca
		# no obj_anim_system, só referenciar eles, o nome deles, se vai estar em "Loop"
		# e se a animação vai dar um "force_play" independente.
		_set_anim(entries[0], entries_names[0], entries_loops[0], false)
		
	else:
		character.velocity.x = move_toward(character.velocity.x, 0, parent.generic_speed)
	
	# Função do Raycast para detectar quando virar ou não ao dar de
	# cara com paredes.
	if(local_raycast.get_collider() != null):
		# Obtém o que o Raycast atingiu no caminho
		var ray_obj = local_raycast.get_collider()
		 
		# Se o que ele atingiu estiver no grupo de sólidos
		if (ray_obj.is_in_group("solids") and proceed):
			# Troca a direção dele (que aqui é o moving_state)
			moving_state = -moving_state
			proceed = false
			await get_tree().create_timer(Global.raycast_wait,true,true).timeout
			proceed = true
	
	if(local_raycast2.get_collider() == null):
		if proceed:
			moving_state = -moving_state
			proceed = false
			await get_tree().create_timer(Global.raycast_wait,true,true).timeout
			proceed = true
	
	character.move_and_slide()

# Essa é a função mais complexazinha aqui, de resto tu não precisa mudar nada,
# apenas saber como invocar uma animação
func _set_anim(to_play, anim_name, looped : bool, force_play : bool):
	if(character.is_playing != anim_name):
		if(force_play):
			character.setup_new_frame(to_play,looped)
			return
		else:
			if character.get_loop():
				character.setup_new_frame(to_play,looped)
				return
			else:
				return

func _on_animation_finished():
	animator.material.set_shader_parameter("on", 0.0)
	character.set_loop(true)
	if parent.generic_health == 0:
		get_parent().queue_free()

# Função para trocar o pai do raycast para ser o personagem que anda
# assim o raio fica seguindo ele.
func parent_to_body():
	var new_parent = character
	self.remove_child(local_raycast)
	new_parent.add_child(local_raycast)
	
	self.remove_child(local_raycast2)
	new_parent.add_child(local_raycast2)

# Função para detectar colisões de corpos
func body_collision(body: Node2D):
	if body.is_in_group("player"):
		print("Colidi com o Player")

# Função para detectar colisões de Areas (eu não fazia ideia que tinha 2 distintas tá)
func area_collision(area: Area2D):
	if area.is_in_group("player_bullets"):
		calculate_damage(area.localDAMAGE)
		if parent.generic_health != 0:
			apply_damage_shaders()
			_set_anim(entries[1], entries_names[1], entries_loops[1], true)
		if area.localPENETRATE > 0:
			area.localPENETRATE -= 1
		else:
			area.queue_free()

# Funçãozinha simples pra dar dano, e se o dano for maior que a vida
# só setar ela pra 0.
func calculate_damage(damage: float):
	if(damage <= parent.generic_health):
		parent.generic_health -= damage
	else:
		parent.generic_health = 0
		
	if parent.generic_health == 0:
		_set_anim(entries[2], entries_names[2], entries_loops[2], true)

func apply_damage_shaders():
	animator.material.set_shader_parameter("on", 1.0)

# Auto-explicativo
func unalive_me():
	get_parent().queue_free()


# Considerações finais: Isso é um arquivo I.A
# Um arquivo muito poderoso que altera todas as propriedades do inimigo, 
# assim como no Terraria. Pra cada I.A que fizermos, dá pra mudar a lógica por
# completo, ele ser um peixe, um inimigo que voa, ter 5 braços, ser anãozinho
# TUDO o que for manipular o objeto de inimigo, deverá ser feito aqui.

# Use esse arquivo como exemplo de como fazer as coisas. Para adicionar
# uma I.A pra um objeto de inimigo, só arrastar sua cena pro campo de Ai Type
