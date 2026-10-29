class_name Projectile extends Area2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

@export var speed: float = 50
@export var damage: float = 30

var defense_type: StringName
var object_type: StringName
var target: Danger = null
var old_direction: Vector2 = Vector2.RIGHT


func _ready() -> void:
	animated_sprite.play("fly")
	area_entered.connect(_on_area_entered)


func lunch(type: StringName, new_target: Danger) -> void:
	defense_type = type
	object_type = new_target.type
	target = new_target


func _on_area_entered(area: Area2D) -> void:
	var danger := area.get_parent() as Danger
	if danger == null:
		return

	if target == danger and AttackRules.can_damage(defense_type, danger.type):
		var multiplier := AttackRules.get_damage_multiplier(
			defense_type,
			danger.type
		)

		var final_damage := damage * multiplier
		danger._takeDamage(final_damage)
		destory()


func destory() -> void:
	queue_free()


func _physics_process(delta: float) -> void:
	if not is_instance_valid(target):
		global_position += old_direction * delta * speed
		return

	if target.is_dying or target.is_invading:
		global_position += old_direction * delta * speed
		return
	
	var direction := global_position.direction_to(target.global_position)
	if direction.length_squared() > 0.0:
		global_rotation = direction.angle()
		old_direction = direction
		
	global_position = global_position.move_toward(target.global_position,speed * delta)
