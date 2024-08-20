extends Node2D

var parent = null
var character = null
var animator = null
var spr_frames = null
var detection_area = null

var entries := []
var entries_names := []
var entries_loops := []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:	
	
	parent = get_parent()
	# Pega o objeto pai pra usá-lo depois
	
	character = parent.anim_system
	# Ele vai pegar o sistema automático de animações, em que é um
	# CharacterBody2D (basicamente tudo o que iremos manipular)
	
	animator = character.obj_anim
	# Pega o AnimatedSprite2D do sistema de animações pra usarmos 
	# com o objetivo de tocar alguma animação ou afins
	
	spr_frames = animator.sprite_frames
	# Referencia os sprite frames do AS2D, mas não é necessário tocar
	# nele
	
	detection_area = character.detect_collisions
	# Feito pra obter o objeto de Area2D, é uma 2° colisão dentro do
	# inimigo para detectar coisas mesclando com ele.
	
	# Esses 2 códigos abaixo são pra caso seja necessário criar uma conexão com
	# os sinais de colisão.
	detection_area.body_entered.connect(body_collision)
	detection_area.area_entered.connect(area_collision)
	
	# Esse já é feito pra se conectar a um sinal de animação
	animator.animation_finished.connect(_on_animation_finished)
	
	# Armazena todas as entries de animação obtidas no objeto de Animation
	entries = [character.anim_entry0,character.anim_entry1,character.anim_entry2,
	character.anim_entry3,character.anim_entry4,character.anim_entry5,character.anim_entry6,
	character.anim_entry7,character.anim_entry8,character.anim_entry9]
	
	entries_names = []
	entries_loops = []
	
	for i in entries.size():
		if entries[i] != null:
			entries_names.append(entries[i].get_animation_names()[0])
			entries_loops.append(entries[i].get_animation_loop(entries_names[i]))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	# Aqui que entra as mecânicas da I.A, o tipo de movimento, detecções e afins.
	# O script dumb_ai possui um exemplo de mecânica de movimento simples.
	
	# Tocamos apenas uma animação IDLE básica vinda da entry 0 para exibição
	# do inimigo
	_set_anim(entries[0], entries_names[0], entries_loops[0], false)
	pass

# Função feita para tocar qualquer tipo de animação, não é necessário mexer nela
# pois funciona de forma standalone, só chamar com os parâmetros certos e é isso.
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

# Feito para detectar quando uma animação sem loop termina. Bom para utilizar
# em I.As que o inimigo morre e precisa tocar uma animação de morte. O dumb_ai
# possui um exemplo disso.
func _on_animation_finished():
	print("Terminei a animação!")
	
	# Esse código abaixo é importante pra não freezar a atual animação.
	character.set_loop(true)
	pass

# Função chamada quando algum CharacterBody2D ou afins colide com nosso objeto.
func body_collision(body: Node2D):
	if body.is_in_group("player"):
		print("Colidi com o Player")

# Essa função é chamada apenas e unicamente quando um objeto Area2D colide com
# o nosso.
func area_collision(area: Area2D):
	if area.is_in_group("player_bullets"):
		#calculate_damage(area.localDAMAGE)
		#apply_damage_shaders()
		print("Colidi com uma bala do player")
		pass

# (OPCIONAL) Função que calcula um dano vindo de algo e então aplica no HP
# do nosso inimigo. Está aqui apenas pra manter presença.
func calculate_damage(damage: float):
	if(damage <= parent.generic_health):
		parent.generic_health -= damage
	else:
		parent.generic_health = 0
		
	if parent.generic_health == 0:
		# Esse código irá tocar uma animação de morte, defina ela em algum
		# entry e então substitua os 0 daqui pelo número da sua entry
		_set_anim(entries[0], entries_names[0], entries_loops[0], true)

# (OPCIONAL) Está aqui apenas como exemplo, ela aplica um shaders que brilha
# o nosso inimigo em Branco pra dar um feedback de acerto.
func apply_damage_shaders():
	animator.material.set_shader_parameter("on", 1.0)
