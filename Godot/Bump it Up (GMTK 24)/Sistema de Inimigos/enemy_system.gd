extends Node2D

@export var ai_type : PackedScene

@export var has_armor := false

@export var generic_health := 1.0
@export var generic_damage := 1.0
@export var generic_speed := 1.0
@export var gravity_multiplier := 1.0

var global_pos = null

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var anim_system: CharacterBody2D = $obj_anim_system

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if(ai_type != null):
		var ai_instance = ai_type.instantiate()
		add_child(ai_instance)

func _physics_process(delta: float) -> void:
	global_pos = anim_system.global_position
