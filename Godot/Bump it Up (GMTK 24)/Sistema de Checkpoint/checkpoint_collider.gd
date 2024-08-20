extends Node

@onready var animator: AnimatedSprite2D = $AnimatedSprite2D

@export var active := false
@export var hide_anim := false

var looping := false
var is_playing := ""

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not hide_anim:
		if active:
			if not looping:
				play_anim("active")
		else:
			play_anim("inactive")
	
	if hide_anim and animator != null:
		animator.queue_free()
		animator = null

func play_anim(gonna_play):
	if is_playing != gonna_play:
		is_playing = gonna_play
		animator.play(is_playing)



func _on_animation_finished() -> void:
	play_anim("active_loop")
	looping = true
