class_name QuizPopup
extends CanvasLayer

signal question_answered(danger_type: String, correct: bool)
signal quiz_finished()

const QuizData = preload("res://scripts/data/quiz_data.gd")

const COLOR_CORRECT := Color(0.65, 1.0, 0.65)
const COLOR_WRONG := Color(1.0, 0.6, 0.6)

## Nombre de réponses proposées (1 bonne + le reste de mauvaises).
@export var choices_count: int = 4
## Ne pose la question qu'à la PREMIÈRE apparition de chaque type de danger.
## Mettre à false pour la poser à chaque apparition.
@export var ask_only_first_time: bool = true
## Met le jeu en pause pendant la question (le popup, lui, reste actif).
@export var pause_game: bool = true

@onready var _overlay: Control = $Overlay
@onready var _title_label: Label = %TitleLabel
@onready var _question_label: Label = %QuestionLabel
@onready var _answers_box: VBoxContainer = %AnswersBox
@onready var _answer_template: Button = %AnswersBox/AnswerTemplate
@onready var _feedback_label: Label = %FeedbackLabel
@onready var _next_button: Button = %NextButton

var _queue: Array[Dictionary] = []
var _already_asked: Dictionary = {}
var _current: Dictionary = {}
var _active: bool = false
var _answered: bool = false
var _was_paused: bool = false


func _ready() -> void:
	add_to_group("quiz_popup")
	_answer_template.visible = false
	_next_button.pressed.connect(_on_next_pressed)


## À appeler quand un danger apparaît. Accepte une ressource DangerData.
func notify_danger_spawned(danger: Resource) -> void:
	if danger == null:
		return
	ask_about_danger(String(danger.get("type")))


## Pose la question pour un type de danger (ex : "DangerPhishing").
func ask_about_danger(danger_type: String, force: bool = false) -> void:
	if not QuizData.DANGERS.has(danger_type):
		push_warning("QuizPopup : aucune question pour '%s' (ajoutez-le dans quiz_data.gd)." % danger_type)
		return
	if ask_only_first_time and not force and _already_asked.has(danger_type):
		return

	_already_asked[danger_type] = true
	_queue.append(_build_question(danger_type))
	if not _active:
		_open()


## Oublie les dangers déjà posés (utile en début de partie / de niveau).
func reset_asked() -> void:
	_already_asked.clear()


# ---------- Construction de la question ----------

func _build_question(danger_type: String) -> Dictionary:
	var danger: Dictionary = QuizData.DANGERS[danger_type]
	var effective: Array = danger["defenses"]

	# 1 bonne réponse tirée parmi les défenses efficaces.
	var correct_type: String = effective.pick_random()

	# Mauvaises réponses : uniquement des défenses NON efficaces contre ce danger.
	var wrong_pool: Array = []
	for defense_type in QuizData.DEFENSES:
		if not effective.has(defense_type):
			wrong_pool.append(defense_type)
	wrong_pool.shuffle()

	var choices: Array = [correct_type]
	choices.append_array(wrong_pool.slice(0, maxi(choices_count - 1, 1)))
	choices.shuffle()

	var answers: Array = []
	for defense_type in choices:
		var info: Dictionary = QuizData.DEFENSES[defense_type]
		answers.append({
			"type": defense_type,
			"label": info["label"],
			"icon": info["data"].icon,
		})

	var effective_labels := PackedStringArray()
	for defense_type in effective:
		effective_labels.append(QuizData.DEFENSES[defense_type]["label"])

	return {
		"danger_type": danger_type,
		"question": "Quelle défense est efficace contre %s ?" % danger["label"],
		"answers": answers,
		"effective": effective,
		"effective_labels": ", ".join(effective_labels),
		"explanation": danger["explanation"],
	}


# ---------- Affichage ----------

func _open() -> void:
	_active = true
	_was_paused = get_tree().paused
	if pause_game:
		get_tree().paused = true
	_overlay.visible = true
	_show_next_question()


func _show_next_question() -> void:
	_current = _queue.pop_front()
	_answered = false

	_title_label.text = "Nouveau danger !"
	_question_label.text = _current["question"]
	_feedback_label.text = ""
	_next_button.visible = false

	_clear_answers()
	for answer in _current["answers"]:
		var button: Button = _answer_template.duplicate()
		button.visible = true
		button.text = answer["label"]
		if answer["icon"] != null:
			button.icon = answer["icon"]
			button.expand_icon = true
			button.add_theme_constant_override("icon_max_width", 32)
		button.pressed.connect(_on_answer_pressed.bind(answer["type"]))
		_answers_box.add_child(button)


func _on_answer_pressed(defense_type: String) -> void:
	if _answered:
		return
	_answered = true

	var effective: Array = _current["effective"]
	var is_correct := effective.has(defense_type)

	var buttons := _get_answer_buttons()
	var answers: Array = _current["answers"]
	for i in buttons.size():
		var this_type: String = answers[i]["type"]
		if effective.has(this_type):
			buttons[i].self_modulate = COLOR_CORRECT
		elif this_type == defense_type:
			buttons[i].self_modulate = COLOR_WRONG

	if is_correct:
		_feedback_label.text = "Bonne réponse !\n%s" % _current["explanation"]
	else:
		_feedback_label.text = "Raté ! Défenses efficaces : %s.\n%s" % [
			_current["effective_labels"], _current["explanation"]
		]

	_next_button.text = "Suivant" if not _queue.is_empty() else "Continuer"
	_next_button.visible = true

	question_answered.emit(_current["danger_type"], is_correct)


func _on_next_pressed() -> void:
	if _queue.is_empty():
		_close()
	else:
		_show_next_question()


func _close() -> void:
	_overlay.visible = false
	_active = false
	if pause_game:
		get_tree().paused = _was_paused
	quiz_finished.emit()


# ---------- Utilitaires ----------

func _get_answer_buttons() -> Array[Button]:
	var result: Array[Button] = []
	for child in _answers_box.get_children():
		if child is Button and child != _answer_template:
			result.append(child)
	return result


func _clear_answers() -> void:
	for button in _get_answer_buttons():
		_answers_box.remove_child(button)
		button.queue_free()
