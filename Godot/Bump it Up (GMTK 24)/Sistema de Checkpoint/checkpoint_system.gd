extends Node2D

@export var checkpoint_data: Resource
@export var incremental := false
@export var persistent := true
@export var checkpoint_path := "checkpoint_data.tres"
@export var player_path := "player_data.tscn"

var user_file_path = "user://"
var collectable_type = "collectable_"
var enemy_type = "enemy_"
var data_extension = "_data.tscn"
var world = null

# Variável pra armazenar todos os checkpoints do nível
var level_checkpoints = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	world = get_parent()
	check_for_dir(user_file_path + world.name + "/")
	
	connect_children_signals()
	if persistent:
		load_checkpoint_data()
	pass # Replace with function body.

func move_to_checkpoint(obj, point = checkpoint_data.current_index):
	obj.global_position = get_child(point).global_position

func check_for_dir(data_path):
	if FileAccess.file_exists(data_path):
		user_file_path = data_path
		return true
	else:
		DirAccess.make_dir_recursive_absolute(data_path.get_base_dir())
		user_file_path = data_path

func save_checkpoint_data(data_path = (user_file_path + checkpoint_path)):
	var error = ResourceSaver.save(checkpoint_data, data_path)
	if error != OK:
		print("Erro ao tentar salvar dados de checkpoint, TYPE: ", error)

func load_checkpoint_data(data_path = (user_file_path + checkpoint_path)):
	if FileAccess.file_exists(data_path):
		checkpoint_data = ResourceLoader.load(data_path)
		
func connect_children_signals():
	for child in get_children():
		child.body_entered.connect(self._on_checkpoint_collided.bind(child.get_index()))
		level_checkpoints.append(child)

func _on_checkpoint_collided(body: Node2D, checkpoint_index):
	if body.is_in_group("player"):
		if incremental:
			if checkpoint_index > checkpoint_data.current_index:
				_set_all_inactive()
				checkpoint_data.current_index = checkpoint_index
		else:
			checkpoint_data.current_index = checkpoint_index
			_set_all_inactive()
			
		_set_current_active(checkpoint_data.current_index)	
		save_checkpoint_data()

func _set_all_inactive():
	for checkpoint in level_checkpoints:
		checkpoint.active = false

func _set_current_active(current_index):
	level_checkpoints[current_index].active = true
