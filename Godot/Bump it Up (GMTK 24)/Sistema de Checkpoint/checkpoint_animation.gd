extends Area2D

@onready var sprite: AnimatedSprite2D = $sprite
@onready var collision: CollisionShape2D = $collision


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite.play("unchecked")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		sprite.play("rising")
		
		await sprite.animation_finished
		
		sprite.play("checked")
		
		collision.set_deferred("disabled", true)
