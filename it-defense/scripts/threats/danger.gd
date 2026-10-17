class_name Danger
extends Node2D

@export var data: DangerData

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var health: float
var lane: int

var is_invading: bool = false
var is_dying: bool = false

func _ready() -> void:
	health = data.max_health
	animated_sprite.play("walk")
	animated_sprite.animation_finished.connect(_on_animation_finished)


func _on_animation_finished() -> void:
	if animated_sprite.animation == &"die":
		destory()
	if animated_sprite.animation == &"invading":
		destory()


func _takeDamage(damage) -> void:
	health -= damage
	if (health <= 0):
		die()


func die() -> void:
	is_dying = true
	animated_sprite.play("die")


func invade() -> void:
	is_invading = true
	animated_sprite.play("invading")


func destory() -> void:
	queue_free()


func _process(delta: float) -> void:
	if is_dying or is_invading:
		return
	
	position.x -= delta * data.speed
	_takeDamage(10 * delta)
