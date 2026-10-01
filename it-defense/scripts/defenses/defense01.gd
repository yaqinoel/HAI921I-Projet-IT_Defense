extends Node2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var attacking: bool = false

func _ready() -> void:
	animated_sprite.animation_finished.connect(_on_animation_dinished)
	animated_sprite.play("idle")
	
func play_attack_animation() -> void:
	if attacking:
		return
	attacking = true
	animated_sprite.play("attack")
	
func _on_animation_dinished() -> void:
	if animated_sprite.animation == &"attack":
		attacking = false
		animated_sprite.play("idle")
