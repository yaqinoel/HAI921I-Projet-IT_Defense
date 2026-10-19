class_name Projectile extends Area2D

var speed: float = 50
var target: Danger = null
var damage: float = 30
var old_direction: Vector2 = Vector2.RIGHT


func _ready() -> void:
	area_entered.connect(_on_area_entered)


func lunch(new_target: Danger) -> void:
	target = new_target


func _on_area_entered(area: Area2D) -> void:
	var danger := area.get_parent() as Danger
	if danger == null or target == null:
		return
	
	if target != danger:
		return
	
	danger._takeDamage(damage)
	
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
