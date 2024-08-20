extends Area2D

@export var is_active: bool = false
@export var is_binded: bool = false

@export var gun_pickup_texture: Texture2D = null
@export var gun_texture: Texture2D = null
@export var gun_bullet_type: PackedScene
@export var gun_cooldown: float
@export var bullet_ammo: int
@export var bullet_penetration: float
@export var bullet_speed: float
@export var bullet_max_distance: float
@export var bullet_damage: float

@onready var gun_sprite: Sprite2D = $gun_sprite
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D


var cooldown_timer: float = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if(gun_pickup_texture != null and not is_binded):
		gun_sprite.texture = gun_pickup_texture
		gun_pickup_texture = null
		
	if Input.is_action_just_pressed("mouse_click"):
		if(is_active and is_binded):
			shoot_weapon()

func shoot_weapon():
	if(cooldown_timer <= 0):
		if(bullet_ammo != -1 and bullet_ammo == 0): return
		var bullet_instance = gun_bullet_type.instantiate()
		var root = get_tree().get_root()
		root.add_child(bullet_instance)
		bullet_instance.transform = self.global_transform
		bullet_instance.setParams(get_parent().animation.scale.x, bullet_penetration, bullet_damage, bullet_speed, bullet_max_distance)
		if(bullet_ammo > 0): bullet_ammo -= 1
		cooldown_timer = gun_cooldown
		await get_tree().create_timer(cooldown_timer).timeout
		cooldown_timer = 0

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		get_parent().remove_child(self)
		body.add_child(self)
		
		global_position = body.global_position

		is_binded = true
		is_active = true
		pickup_sprite()
		collision_shape_2d.set_deferred("disabled", true)

func pickup_sprite():
	if(gun_texture != null):
		gun_sprite.texture = gun_texture
		gun_texture = null
	else:
		gun_sprite.texture = null
