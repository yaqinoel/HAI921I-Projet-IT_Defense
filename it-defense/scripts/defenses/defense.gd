class_name Defense extends Node2D

@export var damage: float = 30
@export var max_position_gap: float = 150.0

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
	if data == null or data.projectile_scene == null:
		push_warning("DefenseData or Projectile Scene not configured")
		return
		
	var new_projecticle = data.projectile_scene.instantiate() as Node2D
	projectile_container.add_child(new_projecticle)
	
	new_projecticle.global_position = muzzle.global_position
	new_projecticle.lunch(data.type, target)


func find_target() -> Danger:
	var target: Danger = null
	var best_damage: float = -1.0
	var best_pos : float = 10000

	for detection_area in detection_areas:
		if not is_instance_valid(detection_area):
			continue

		for danger in detection_area.get_targets():
			if not is_instance_valid(danger):
				continue

			if danger.is_dying or danger.is_invading:
				continue

			# Les dangers doivent être à droite de la défense.
			if danger.global_position.x <= global_position.x:
				continue

			# Ignore les dangers que cette défense ne peut pas toucher.
			if not AttackRules.can_damage(data.type, danger.type):
				continue

			var effective_damage := AttackRules.get_effective_damage(
				data.type,
				danger.type,
				damage
			)

			if target == null:
				target = danger
				best_damage = effective_damage
				best_pos = danger.global_position.x
				continue
			if (danger.global_position.x < best_pos - max_position_gap):
				target = danger
				best_damage = effective_damage
				best_pos = danger.global_position.x
				continue
			# Le danger le plus à gauche est prioritaire.
			if (effective_damage > best_damage and danger.global_position.x < best_pos + max_position_gap):
				target = danger
				best_damage = effective_damage

	return target


func _on_attack_timer_timeout() -> void:
	if attacking:
		return
		
	var target := find_target()
	if target == null:
		return
	
	play_attack_animation()
	
	lunch_projectile_to_target(target)
