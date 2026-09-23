class_name Danger
extends Node2D
@export var speed = 100.0
@export var max_health = 50
@export var damage = 20

var health
var lane

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health = max_health
	lane = randi_range(0,2)
	_startPos(lane)
	pass # Replace with function body.

func _startPos(lane) -> void:
	position.x = 900
	position.y = 100 + 200 * lane
	 
func _takeDamage(damage) -> void:
	health -= damage
	if (health <= 0):
		die()
		
func die() -> void:
	queue_free()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.x -= delta * speed
	_takeDamage(0.1)
