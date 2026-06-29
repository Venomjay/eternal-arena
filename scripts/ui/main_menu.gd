extends Control

class_name MainMenu

@onready var title_label = Label.new()
@onready var play_button = Button.new()
@onready var practice_button = Button.new()
@onready var settings_button = Button.new()
@onready var quit_button = Button.new()

var vbox_container: VBoxContainer

func _ready() -> void:
	setup_ui()
	play_button.pressed.connect(_on_play_pressed)
	practice_button.pressed.connect(_on_practice_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func setup_ui() -> void:
	anchor_left = 0.0
	anchor_top = 0.0
	anchor_right = 1.0
	anchor_bottom = 1.0
	
	title_label.text = "ETERNAL ARENA"
	title_label.add_theme_font_size_override("font_size", 80)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.modulate = Color.GOLD
	
	play_button.text = "PLAY"
	play_button.custom_minimum_size = Vector2(300, 60)
	practice_button.text = "PRACTICE"
	practice_button.custom_minimum_size = Vector2(300, 60)
	settings_button.text = "SETTINGS"
	settings_button.custom_minimum_size = Vector2(300, 60)
	quit_button.text = "QUIT"
	quit_button.custom_minimum_size = Vector2(300, 60)
	
	vbox_container = VBoxContainer.new()
	vbox_container.add_child(title_label)
	vbox_container.add_spacer(false)
	vbox_container.add_child(play_button)
	vbox_container.add_child(practice_button)
	vbox_container.add_child(settings_button)
	vbox_container.add_child(quit_button)
	vbox_container.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox_container.add_theme_constant_override("separation", 20)
	
	add_child(vbox_container)

func _on_play_pressed() -> void:
	GameManager.change_state(GameManager.GameState.CHARACTER_SELECT)

func _on_practice_pressed() -> void:
	print("Practice Mode - Not yet implemented")

func _on_settings_pressed() -> void:
	print("Settings - Not yet implemented")

func _on_quit_pressed() -> void:
	get_tree().quit()
