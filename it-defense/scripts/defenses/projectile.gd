class_name Projectile extends Area2D

var speed: float = 50

var target: Danger = null

func _ready() -> void:
	pass


func destory() -> void:
	queue_free()


func _process(delta: float) -> void:
	position.x += delta * speed
