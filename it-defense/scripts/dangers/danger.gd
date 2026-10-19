class_name Danger
extends Node2D

@export var data: DangerData

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var normal_color: Color = animated_sprite.modulate

var hit_tween: Tween

var health: float
var lane: int

var is_invading: bool = false
var is_dying: bool = false

var type: StringName

func _ready() -> void:
	type = data.type
	health = data.max_health
	animated_sprite.play("walk")
	animated_sprite.animation_finished.connect(_on_animation_finished)


func _on_animation_finished() -> void:
	if animated_sprite.animation == &"die":
		destory()
	if animated_sprite.animation == &"invading":
		destory()


func _takeDamage(damage) -> void:
	if is_dying or is_invading:
		return
		
	health -= damage
	
	flash_red()
	
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


func flash_red() -> void:
	if hit_tween != null and hit_tween.is_valid():
		hit_tween.kill()
	
	animated_sprite.modulate = Color(1.0, 0.1, 0.1, normal_color.a * 0.5)
	
	hit_tween = create_tween()
	hit_tween.tween_interval(0.08)
	hit_tween.tween_property(animated_sprite, "modulate", normal_color, 0.12)


func _process(delta: float) -> void:
	if is_dying or is_invading:
		return
	
	position.x -= delta * data.speed
	if position.x < 0.0:
		destory()
