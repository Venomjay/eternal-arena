extends Control

class_name CharacterSelector

@export var characters: Array[String] = [
	"knight_male",
	"knight_female",
	"assassin_male",
	"assassin_female",
	"mage_male",
	"mage_female"
]

var selected_character: String = ""
var character_buttons: Array[Button] = []
var hbox_container: HBoxContainer
var confirm_button: Button
var title_label: Label

func _ready() -> void:
	setup_ui()

func setup_ui() -> void:
	anchor_left = 0.0
	anchor_top = 0.0
	anchor_right = 1.0
	anchor_bottom = 1.0
	
	title_label = Label.new()
	title_label.text = "SELECT YOUR CHARACTER"
	title_label.add_theme_font_size_override("font_size", 60)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.modulate = Color.GOLD
	add_child(title_label)
	
	hbox_container = HBoxContainer.new()
	hbox_container.add_theme_constant_override("separation", 10)
	hbox_container.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox_container.offset_top = 150
	
	for char in characters:
		var btn = Button.new()
		btn.text = char.to_upper()
		btn.custom_minimum_size = Vector2(200, 100)
		btn.pressed.connect(_on_character_selected.bindv([char]))
		character_buttons.append(btn)
		hbox_container.add_child(btn)
	
	add_child(hbox_container)
	
	confirm_button = Button.new()
	confirm_button.text = "CONFIRM"
	confirm_button.custom_minimum_size = Vector2(300, 60)
	confirm_button.offset_top = 400
	confirm_button.offset_left = (get_viewport_rect().size.x - 300) / 2
	confirm_button.pressed.connect(_on_confirm_pressed)
	confirm_button.disabled = true
	add_child(confirm_button)

func _on_character_selected(character: String) -> void:
	selected_character = character
	confirm_button.disabled = false
	for i in range(character_buttons.size()):
		if characters[i] == character:
			character_buttons[i].modulate = Color.YELLOW
		else:
			character_buttons[i].modulate = Color.WHITE

func _on_confirm_pressed() -> void:
	if selected_character != "":
		GameManager.player_character = selected_character
		GameManager.change_state(GameManager.GameState.ARENA_SELECT)
