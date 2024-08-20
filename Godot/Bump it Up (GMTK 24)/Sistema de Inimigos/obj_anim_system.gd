extends CharacterBody2D

@export var anim_entry0 : SpriteFrames
@export var anim_entry1 : SpriteFrames
@export var anim_entry2 : SpriteFrames
@export var anim_entry3 : SpriteFrames
@export var anim_entry4 : SpriteFrames
@export var anim_entry5 : SpriteFrames
@export var anim_entry6 : SpriteFrames
@export var anim_entry7 : SpriteFrames
@export var anim_entry8 : SpriteFrames
@export var anim_entry9 : SpriteFrames

@export var anim_speed_scale := 0.0

@export var collision_width : int
@export var collision_height : int

@onready var obj_collision : CollisionShape2D = $obj_collision
@onready var obj_anim : AnimatedSprite2D = $obj_anim
@onready var detect_collisions: Area2D = $detect_collisions
@onready var collision_area: CollisionShape2D = $detect_collisions/collision_area

var is_playing = ""

# Recomendo ignorar esse script, levou horas pra ser feito, mas ele
# lida de forma dinâmica com todas as animações que você pode enviar
# pro player, sem qualquer limite, sem spammar ela, bug-free.

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	obj_collision.shape.extents = Vector2(collision_width, collision_height)
	collision_area.shape.extents = Vector2(collision_width * 1.1, collision_height * 1.1)
	is_playing = obj_anim.sprite_frames.get_animation_names()[0]


# Sempre que precisar trocar a animação chamar essa função
# Pode ser quando o bixo for atacar, andar e etc.
func setup_new_frame(new_frame : SpriteFrames, new_loop : bool):
	var old_name = obj_anim.sprite_frames.get_animation_names()[0]
	obj_anim.sprite_frames = new_frame
	print("Recebido novo sprite frame")
	play_frame(old_name, new_frame, new_loop)

func play_frame(obj_old_name : String, obj_spriteframe : SpriteFrames, obj_loop : bool):
	var animation_name = obj_spriteframe.get_animation_names()[0]
	is_playing = animation_name
	obj_anim.sprite_frames.rename_animation(obj_old_name, animation_name)
	obj_anim.sprite_frames.set_animation_loop(animation_name,obj_loop)

	obj_anim.play(animation_name)
	obj_anim.speed_scale = anim_speed_scale
	print("Tocado novo sprite frame")

# Funções básicas de Getter/Setter
func get_loop() -> bool:
	return obj_anim.sprite_frames.get_animation_loop(is_playing)

func set_loop(new_loop : bool):
	obj_anim.sprite_frames.set_animation_loop(is_playing, new_loop)
