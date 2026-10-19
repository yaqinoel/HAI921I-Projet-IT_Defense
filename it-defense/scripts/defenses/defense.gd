class_name Defense extends Node2D

@export var projectile: PackedScene = null

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var muzzle: Marker2D = $Muzzle
@onready var attack_timer: Timer = $AttackTimer
@onready var projectile_container: Node2D = $"../../ProjectileContainer"

var data: DefenseData
var detection_areas: Array[DangerDetectionArea] = []
var attacking: bool = false


func _ready() -> void:
	animated_sprite.animation_finished.connect(_on_animation_finished)
	animated_sprite.play("idle")
	
	attack_timer.wait_time = data.attack_interval
	attack_timer.timeout.connect(_on_attack_timer_timeout)
	attack_timer.start()


func play_attack_animation() -> void:
	if attacking:
		return
	attacking = true
	animated_sprite.play("attack")


func _on_animation_finished() -> void:
	if animated_sprite.animation == &"attack":
		attacking = false
		animated_sprite.play("idle")


func lunch_projectile_to_target(target: Danger) -> void:
	if projectile == null:
		return
		
	var new_projecticle = projectile.instantiate() as Node2D
	projectile_container.add_child(new_projecticle)
	
	new_projecticle.global_position = muzzle.global_position
	new_projecticle.lunch(data.type, target)


func is_attackable(danger: Danger) -> bool:
#	TODO
#	to see if a danger is attackable according our rules
	return true


func find_target() -> Danger:
	var target: Danger = null

	for detection_area in detection_areas:
		if not is_instance_valid(detection_area):
			continue

		for danger in detection_area.get_targets():
			if target == null or danger.global_position.x < target.global_position.x and danger.global_position.x > global_position.x:
				if is_attackable(danger):
					target = danger
				else: continue

	return target


func _on_attack_timer_timeout() -> void:
	if attacking:
		return
		
	var target := find_target()
	if target == null:
		return
	
	play_attack_animation()
	
	lunch_projectile_to_target(target)
