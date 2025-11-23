extends Control

@onready var rich_text_label:RichTextLabel = $RichTextLabel
@onready var char_timer:Timer = $char_timer

var text_array: String = ""
var queued_letter: String = ""
var i:int = 0

const CHARACTER_DELAY:float = 0.10
const CLEAR_DELAY:float = 2.0

const PUNCTUATION:Array[String] = ["!?,."]
const PUNCTUATION_DELAY:float = 0.2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rich_text_label.text = ""
	char_timer.timeout.connect(_on_timer_timeout)
	
	init_text()
	write_next_char()

func write_next_char()->void:
	var cur_char:String = text_array[i]
	var delay:float = 0.1
	
	if cur_char == "#":
		delay = CLEAR_DELAY
		queued_letter = "#"
	elif cur_char in PUNCTUATION:
		delay = PUNCTUATION_DELAY
		queued_letter = cur_char
	elif cur_char == "/":
		delay = PUNCTUATION_DELAY
		queued_letter = "\n"
	else:
		delay = CHARACTER_DELAY
		queued_letter = cur_char
	
	char_timer.start(delay)

func _on_timer_timeout()->void:
	i += 1
	if queued_letter == "#":
		rich_text_label.text = ""
	else:
		rich_text_label.text += queued_letter
	
	queued_letter = ""

	if i >= text_array.length():
		i = 0
		rich_text_label.text = ""
		
	write_next_char()

func init_text()->void:
	text_array += "Welcome/Welcome/Welcome"
	text_array += "#"

	text_array += "divorcedatforty/welcomes/you"

	text_array += "#"
	
	text_array += "Our mobile support is .../not good.../and we do not plan to improve it until the desktop experience is complete."

	text_array += "#"

	text_array += "Give us a visit on Desktop"
	text_array += "//"
	text_array += "Thanks........."
