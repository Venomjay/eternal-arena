extends Control

class_name VictoryScreen

var title_label: Label
var stats_label: Label
var reward_label: Label
var continue_button: Button

func _ready() -> void:
	setup_ui()

func setup_ui() -> void:
	anchor_left = 0.0
	anchor_top = 0.0
	anchor_right = 1.0
	anchor_bottom = 1.0
	
	title_label = Label.new()
	title_label.text = "VICTORY!"
	title_label.add_theme_font_size_override("font_size", 100)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.modulate = Color.GREEN
	title_label.offset_top = 150
	add_child(title_label)
	
	stats_label = Label.new()
	stats_label.text = "Opponent Defeated!"
	stats_label.add_theme_font_size_override("font_size", 40)
	stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stats_label.offset_top = 300
	add_child(stats_label)
	
	reward_label = Label.new()
	reward_label.text = "Gold: +100\nExperience: +50"
	reward_label.add_theme_font_size_override("font_size", 30)
	reward_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	reward_label.offset_top = 400
	add_child(reward_label)
	
	continue_button = Button.new()
	continue_button.text = "CONTINUE"
	continue_button.custom_minimum_size = Vector2(300, 60)
	continue_button.offset_top = 600
	continue_button.offset_left = (get_viewport_rect().size.x - 300) / 2
	continue_button.pressed.connect(_on_continue_pressed)
	add_child(continue_button)

func _on_continue_pressed() -> void:
	GameManager.change_state(GameManager.GameState.MENU)
