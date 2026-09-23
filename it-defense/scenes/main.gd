extends Node2D


# Called when the node enters the scene tree for the first time.
@export var virus: PackedScene
@export var phising: PackedScene
@export var intervalle := 2.0

@onready var timer: Timer = $Timer

func _ready():
	timer.wait_time = intervalle
	timer.timeout.connect(spawn_objet)
	timer.start()

func spawn_objet():
	var rand = randi_range(0,1)
	var nouvel_objet
	if (rand == 0) :
		nouvel_objet = virus.instantiate()
	if (rand == 1) :
		nouvel_objet = phising.instantiate()
	add_child(nouvel_objet)
	
	#nouvel_objet.position = Vector2(500, 300)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
