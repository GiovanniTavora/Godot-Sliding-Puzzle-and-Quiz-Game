extends Node

enum QuestionType { TEXT, IMAGE, VIDEO, AUDIO }

export(Resource) var bd_quiz
export(Color) var color_right
export(Color) var color_wrong

var buttons := []
var index := 0
var quiz_shuffle := []
var correct := 0
var timer := 15
var score := 0

onready var question_texts := $question_info/txt_question
onready var question_image := $question_info/image_holder/question_Image
onready var question_video := $question_info/image_holder/question_video
onready var question_audio := $question_info/image_holder/question_audio

func _ready() -> void:
	for _button in $question_holder.get_children():
		buttons.append(_button)

	quiz_shuffle = randomize_array(bd_quiz.bd)
	load_quiz()

func load_quiz() -> void:
	if index >= bd_quiz.bd.size():
		game_over()
		return

	question_texts.text = str(quiz_shuffle[index].question_info)

	var options = randomize_array(bd_quiz.bd[index].options)
	for i in buttons.size():
		buttons[i].text = str(options[i])

	match bd_quiz.bd[index].type:
		QuestionType.TEXT:
			$question_info/image_holder.hide()

		QuestionType.IMAGE:
			$question_info/image_holder.show()
			question_image.texture = bd_quiz.bd[index].question_image

		QuestionType.VIDEO:
			$question_info/image_holder.show()
			question_video.stream = bd_quiz.bd[index].question_video
			question_video.play()

		QuestionType.AUDIO:
			$question_info/image_holder.show()
			question_image.texture = load("res://Quiz/sprites/sound.png")
			question_audio.stream = bd_quiz.bd[index].question_audio
			question_audio.play()

	connect_buttons()  # Adicione esta linha para conectar os botões

func connect_buttons() -> void:
	for i in buttons.size():
		var key = ""
		match i:
			0: key = "Q"
			1: key = "W"
			2: key = "E"
			3: key = "R"

		buttons[i].connect("pressed", self, "buttons_answer", [buttons[i], key])

func buttons_answer(button, key) -> void:
	if bd_quiz.bd[index].correct == button.text:
		button.modulate = color_right
		correct += 1
		score += 5
		$audio_correct.play()
	else:
		button.modulate = color_wrong
		$audio_incorrect.play()

	_next_question()

func _next_question() -> void:
	question_audio.stop()
	question_video.stop()
	timer = 15

	yield(get_tree().create_timer(1), "timeout")
	for bt in buttons:
		bt.modulate = Color.white

	question_audio.stream = null
	question_video.stream = null
	index += 1
	load_quiz()

func randomize_array(array: Array) -> Array:
	randomize()
	var array_temp := array
	array_temp.shuffle()
	return array_temp

func game_over() -> void:
	$game_over.show()
	$game_over/txt_result.text = str("Você acertou ", correct, " de ", bd_quiz.bd.size(), " perguntas!")
	$game_over/txt_points.text = str("Pontuação: ", score)
	$timer.stop()
	$txt_timer.hide()
	$tempo.hide()

func _on_timer_timeout() -> void:
	$txt_timer.text = str(timer)
	timer -= 1

	if timer < 0:
		_next_question()

func _on_voltar_menu_pressed():
	get_tree().change_scene("res://menu_principal.tscn")

# Adicione a função _input para capturar a entrada do teclado
func _input(event):
	if event is InputEventKey and event.pressed:
		buttons_answer_for_key(event)
		
# Função para lidar com as teclas pressionadas
func buttons_answer_for_key(event):
	for i in range(buttons.size()):
		var key = ""
		match i:
			0: key = KEY_Q
			1: key = KEY_W
			2: key = KEY_E
			3: key = KEY_R

		if event.scancode == key:
			buttons_answer(buttons[i], str(i + 1))
