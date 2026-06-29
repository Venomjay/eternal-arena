extends Control

class_name DefeatScreen

var title_label: Label
var stats_label: Label
var retry_button: Button
var menu_button: Button

func _ready() -> void:
	setup_ui()

func setup_ui() -> void:
	anchor_left = 0.0
	anchor_top = 0.0
	anchor_right = 1.0
	anchor_bottom = 1.0
	
	title_label = Label.new()
	title_label.text = "DEFEAT"
	title_label.add_theme_font_size_override("font_size", 100)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.modulate = Color.RED
	title_label.offset_top = 150
	add_child(title_label)
	
	stats_label = Label.new()
	stats_label.text = "You were defeated!"
	stats_label.add_theme_font_size_override("font_size", 40)
	stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stats_label.offset_top = 300
	add_child(stats_label)
	
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 20)
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.offset_top = 500
	
	retry_button = Button.new()
	retry_button.text = "RETRY"
	retry_button.custom_minimum_size = Vector2(200, 60)
	retry_button.pressed.connect(_on_retry_pressed)
	hbox.add_child(retry_button)
	
	menu_button = Button.new()
	menu_button.text = "MENU"
	menu_button.custom_minimum_size = Vector2(200, 60)
	menu_button.pressed.connect(_on_menu_pressed)
	hbox.add_child(menu_button)
	
	add_child(hbox)

func _on_retry_pressed() -> void:
	GameManager.change_state(GameManager.GameState.ARENA_SELECT)

func _on_menu_pressed() -> void:
	GameManager.change_state(GameManager.GameState.MENU)
