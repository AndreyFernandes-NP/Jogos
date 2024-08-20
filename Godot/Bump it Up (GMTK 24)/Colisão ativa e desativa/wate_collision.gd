extends StaticBody2D

@onready var collision: CollisionShape2D = $collision_water


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		var player = body
		var state_manager = player.state_manager
		if state_manager.is_small == true:
			print("deveria colodir")
			pass
		else:
			print("passa reto")
			collision.set_deferred("disabled", true)

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		collision.set_deferred("disabled", false)
