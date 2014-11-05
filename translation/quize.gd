
extends Node2D

const CONTEXT_COUNT = 1

var statements = null
var answer_options = null
var case = null

var quiz_roadmap = null
var quiz_roadmap_numbers = null
var current_case = null
var current_case_questions = null

var score = 4


func _set_score(n):
	score += n
	get_node("score").set_text("Your score: " + str(score))


class KeyValue:
	var key = null
	var value = null
	var index = null
	
	func _init(_key, _value, _index=null):
		key = _key
		value = _value
		if _index:
			index = _index - 1


class QuestionCreator:
	var context_key = null
	var question_key = null
	var answer_key = null
	var answer_explanation_key = null
	
	func _init(context_index, question_index):
		context_key = "CONTEXT_" + str(context_index)
		question_key = context_key + "_QUESTION_" + str(question_index)
		answer_key = question_key + "_ANSWER"
		answer_explanation_key = answer_key + "_EXPLANATION"
	
	func _get_tr_or_null(key):
		var result = tr(key)
		if key != result:
			return result
	
	func _get_kv_or_null(key, index=null):
		var result = _get_tr_or_null(key)
		if result:
			return KeyValue.new(key, result, index)
		else:
			return null
	
	func get_question():
		return _get_kv_or_null(question_key)
	
	func get_answer():
		return _get_kv_or_null(answer_key)
	
	func get_answer_explanation():
		return _get_kv_or_null(answer_explanation_key)
	
	func get_statement(index):
		var key = context_key + "_STATEMENT_" + str(index)
		return _get_kv_or_null(key, index)
	
	func get_answer_option(index):
		var key = question_key + "_ANSWER_OPTION_" + str(index)
		return _get_kv_or_null(key, index)
		
	func _get_list_of(getter):
		var result = []
		var i = 0
		while true:
			i += 1
			var statement_kv = call(getter, i)  # getter.exec(i)
			#var statement_kv = get_statement(i)  # getter.exec(i)
			#var key = statement_kv.key
			#var val = statement_kv.value
			if statement_kv:
				result.append(statement_kv)
			else:
				break
		return result
	
	func get_statements():
		return _get_list_of("get_statement")  # funcref(self, "get_statement")
	
	func get_answer_options():
		var result = _get_list_of("get_answer_option")  # funcref(self, "get_answer_option")
		result.append(_get_kv_or_null(answer_key))
		return result


class Translator:
	var node = null
	var key = null
	var btn = null
	var plug = null
	var global = null
	
	func _init(_node, _key, _global):
		node = _node
		key = _key
		global = _global
		btn = self.node.get_node("translate")
	
	func _translate():
		var old_l = TranslationServer.get_locale()
		TranslationServer.set_locale("ru")
		var tr_target = node.get_node("translation")
		if tr_target extends Label:
			tr_target.set_text(tr(self.key))
		elif tr_target extends RichTextLabel:
			tr_target.add_text(tr(self.key))
		TranslationServer.set_locale(old_l)
		plug = Control.new()
		node.add_child(plug)
		node.move_child(plug, btn.get_position_in_parent())
		btn.hide()
		node.queue_sort()
		global._set_score(-1)


var translators = []


func _bind_translate(node, kv):
	var k = node.key
	var translator = Translator.new(node, kv.key, self)
	translators.append(translator)
	translator.btn.connect("pressed", translator, "_translate")


class Answerer:
	var node = null
	var is_correct = null
	var btn = null
	var plug = null
	var all_answerer = null
	var explanation = null
	var global = null
	
	func _init(_node, _is_correct, _global):
		node = _node
		is_correct = _is_correct
		global = _global
		btn = node.get_node("select")
	
	func _answer():
		if is_correct:
			global._set_score(4)
		else:
			global.case.get_node("explanation").show()
		for a in global.answerers:
			if a.is_correct:
				a.emphasize()
			a.hide_btn()
	
	func hide_btn():
		plug = Control.new()
		node.add_child(plug)
		node.move_child(plug, btn.get_position_in_parent())
		btn.hide()
		node.queue_sort()
	
	func emphasize():
		node.get_node("answer").add_color_override("font_color", Color(160, 170, 0))
	


var answerers = []


func _bind_answer(node, kv):
	var k = node.key
	var answerer = Answerer.new(node, kv.index == null, self)
	answerers.append(answerer)
	answerer.btn.connect("pressed", answerer, "_answer")


func _pop(list, i=0):
	var result = list[i]
	list.remove(i)
	return result


func _pop_rand(list):
	var r = randf()
	var randi_result = int(r * 100)
	#var randi_result = randi()  Doesn't working
	var i = randi_result % list.size()
	return _pop(list, i)


func _set_question(context_index, question_index):
	var qc = QuestionCreator.new(context_index, question_index)
	for kv in qc.get_statements():
		var statement = statements[kv.index]
		_bind_translate(statement, kv)
		statement.get_node("statement").set_text(kv.value)
	var indexes = range(4)
	for kv in qc.get_answer_options():
		var i = _pop_rand(indexes)
		var answer_option = answer_options[i]
		_bind_translate(answer_option, kv)
		_bind_answer(answer_option, kv)
		answer_option.get_node("answer").set_text(kv.value)
	var question = case.get_node("question")
	var kv = qc.get_question()
	question.get_node("question").set_text(kv.value)
	question.get_node("translation").set_text("")
	_bind_translate(question, kv)
	kv = qc.get_answer_explanation()
	var explanation = case.get_node("explanation")
	explanation.get_node("explanation").add_text(kv.value)
	#explanation.get_node("translation").add_text("")
	_bind_translate(explanation, kv)


func _set_next_question():
	_clear_case()
	if current_case_questions == null or current_case_questions.size() == 0:
		var s = quiz_roadmap.size()
		current_case = _pop_rand(quiz_roadmap_numbers)
		current_case_questions = range(quiz_roadmap[current_case])
	_set_question(current_case + 1, _pop_rand(current_case_questions) + 1)
	#case.get_node("question").hide()
	case.get_node("explanation").hide()
	case.show()
	if quiz_roadmap_numbers.size() == 0 and current_case_questions.size() == 0:
		get_node("next").hide()


func _get_quiz_roadmap():
	var i = 0
	var result = []
	while true:
		var context_key = "CONTEXT_" + str(i + 1)
		var j = 0
		while true:
			var question_key = context_key + "_QUESTION_" + str(j + 1)
			var translation = tr(question_key)
			if question_key == translation:
				break
			j += 1
		if j == 0:
			break
		else:
			quiz_roadmap.append(j)
		i += 1
	quiz_roadmap_numbers = range(quiz_roadmap.size())


func _clear_case():
	for i in range(4):
		var statement = case.get_node("statements").get_node("statement " + str(i + 1))
		statement.get_node("translation").set_text("")
		statements.append(statement)
	for i in range(4):
		var answer_option = case.get_node("answer_options").get_node("answer_option " + str(i + 1))
		answer_option.get_node("translation").set_text("")
		answer_option.get_node("select").show()
		answer_option.get_node("answer").add_color_override("font_color", Color(255, 255, 255))
		answer_options.append(answer_option)
	for tr in translators:
		if tr.plug != null:
			tr.plug.get_parent().remove_child(tr.plug)
		tr.btn.show()
	translators = []
	for a in answerers:
		if a.plug != null:
			a.plug.get_parent().remove_child(a.plug)
		a.btn.show()
	answerers = []


func _fixed_process(delta):
	if Input.is_action_pressed("restart"):
		var global = get_node("/root/global")
		global.goto_scene("res://quize.scn.xml")


func _ready():
	statements = []
	answer_options = []
	quiz_roadmap = []
	_get_quiz_roadmap()
	TranslationServer.set_locale("en")
	case = get_node("case")
	case.hide()
	get_node("next").connect("pressed", self, "_set_next_question")
	_set_score(0)
	set_fixed_process(true)
