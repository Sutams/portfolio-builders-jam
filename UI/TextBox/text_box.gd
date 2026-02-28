extends MarginContainer

const MAX_WIDTH = 128

@onready var label : Label = $MarginContainer/Label
@onready var timer : Timer = $LetterDisplayTimer

var text : String = ""
var letter_index : int = 0
var letter_time : float  = 0.01
var space_time : float  = 0.01
var punctuation_time : float = 0.01
signal finished_displaying

func _display_letter():
	label.text += text[letter_index]
	
	letter_index += 1
	if letter_index >= text.length():
		#await get_tree().create_timer(5).timeout
		#queue_free()
		finished_displaying.emit()
		return
	
	match text[letter_index]:
		"!", ".", ",", "?":
			timer.start(punctuation_time)
		" ":
			timer.start(space_time)
		_:
			timer.start(letter_time)

func display_text(text_to_display : String):
	text = text_to_display
	label.text = text_to_display
	
	await resized
	custom_minimum_size.x = min(size.x, MAX_WIDTH)
	
	if size.x > MAX_WIDTH:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD
		await resized # wait for x resize
		await resized # wait for y resize
		custom_minimum_size.y = size.y

	global_position.x -= size.x / -2
	global_position.y -= (size.y) * scale.y
	label.text = ""
	_display_letter()
	
func _on_letter_display_timer_timeout() -> void:
	_display_letter()
