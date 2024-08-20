extends Area2D

var obj_direction := 0
var localPENETRATE := 0
var localDAMAGE := 0.0
var localSPEED := 0.0
var maxDistance := 0.0

var distanceTRAVELLED = 0
@onready var bullet: Sprite2D = $Bullet

func _ready() -> void:
	add_to_group("player_bullets")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	position += (transform.x * localSPEED) * obj_direction * delta
	distanceTRAVELLED += localSPEED * delta
	
	if(distanceTRAVELLED >= maxDistance):
		self.queue_free()
	
	
func setParams(direction : int, bull_penetration : int, bull_damage : float, bull_speed : float, bull_max_distance : float):
	obj_direction = direction
	localPENETRATE = bull_penetration
	localDAMAGE = bull_damage
	localSPEED = bull_speed
	maxDistance = bull_max_distance


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("solids"):
		self.queue_free()
