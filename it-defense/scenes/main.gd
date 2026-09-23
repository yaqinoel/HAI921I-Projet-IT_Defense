extends Node2D


# Called when the node enters the scene tree for the first time.
@export var virus: PackedScene
@export var intervalle := 2.0

func _ready():
	$Timer.wait_time = intervalle
	$Timer.timeout.connect(spawn_objet)
	$Timer.start()

func spawn_objet():
	var nouvel_objet = virus.instantiate()
	add_child(nouvel_objet)
	
	nouvel_objet.position = Vector2(500, 300)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
