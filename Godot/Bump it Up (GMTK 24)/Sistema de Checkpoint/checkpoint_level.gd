extends Node2D

@onready var checkpoint: Node2D = $Checkpoint2D
var player: CharacterBody2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for nodes in get_children():
		if nodes is CharacterBody2D:
			if nodes.is_in_group("player"):
				player = nodes
	
	checkpoint.move_to_checkpoint(player)

func _on_player_character_2d_died():
	get_tree().reload_current_scene()
