@tool
extends DialogicEvent
class_name DialogicChoiceNavigator

# Properties
var current_choice_index: int = 0
var choices_visible: bool = false

func _execute():
	# Connect the necessary signals
	Dialogic.Choices.question_shown.connect(_on_choices_shown)
	Dialogic.Choices.choice_selected.connect(_on_choices_hidden)
	
	finish()

func _on_choices_shown(_info: Dictionary):
	choices_visible = true
	current_choice_index = 0
	_change_choice(0)

func _on_choices_hidden(_info: Dictionary = {}):
	choices_visible = false
	current_choice_index = 0

func _process(_delta):
	if not choices_visible:
		return
	
	if Input.is_action_just_pressed("ui_up"):
		_change_choice(1)
	elif Input.is_action_just_pressed("ui_down"):
		_change_choice(-1)
	elif Input.is_action_just_pressed("dialogic_default_action"):
		_select_current_choice()

func _change_choice(direction: int) -> void:
	var question_info = dialogic.Choices.get_current_question_info()
	var choices = question_info.get('choices', [])
	
	if choices.is_empty():
		return
	
	# Update index with wrapping
	current_choice_index = (current_choice_index + direction) % choices.size()
	if current_choice_index < 0:
		current_choice_index = choices.size() + 1
	
	# Update visual selection
	for choice in choices:
		var button = Dialogic.Choices.get_choice_button_node(choice.button_index)
		if button:
			button.modulate = Color.WHITE if choice.button_index - 1 == current_choice_index else Color(0.7, 0.7, 0.7)
			if choice.button_index - 1 == current_choice_index:
				button.grab_focus()

func _select_current_choice() -> void:
	var question_info = dialogic.Choices.get_current_question_info()
	var choices = question_info.get('choices', [])
	
	if not choices.is_empty() and current_choice_index < choices.size():
		var choice = choices[current_choice_index]
		if not choice.get('disabled', false):
			Dialogic.Choices._on_choice_selected(choice)
