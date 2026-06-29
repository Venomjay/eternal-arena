extends Control

class_name ArenaSelector

@export var arenas: Array[String] = [
	"ancient_temple",
	"lava_fortress",
	"frozen_kingdom",
	"forest_ruins",
	"celestial_arena"
]

var selected_arena: String = ""
var selected_difficulty: int = 1
var arena_buttons: Array[Button] = []
var difficulty_buttons: Array[Button] = []
var hbox_container: HBoxContainer
var difficulty_hbox: HBoxContainer
var start_button: Button
var title_label: Label

func _ready() -> void:
	setup_ui()

func setup_ui() -> void:
	anchor_left = 0.0
	anchor_top = 0.0
	anchor_right = 1.0
	anchor_bottom = 1.0
	
	title_label = Label.new()
	title_label.text = "SELECT ARENA"
	title_label.add_theme_font_size_override("font_size", 60)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.modulate = Color.GOLD
	add_child(title_label)
	
	hbox_container = HBoxContainer.new()
	hbox_container.add_theme_constant_override("separation", 10)
	hbox_container.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox_container.offset_top = 150
	
	for arena in arenas:
		var btn = Button.new()
		btn.text = arena.to_upper().replace("_", " ")
		btn.custom_minimum_size = Vector2(250, 80)
		btn.pressed.connect(_on_arena_selected.bindv([arena]))
		arena_buttons.append(btn)
		hbox_container.add_child(btn)
	
	add_child(hbox_container)
	
	difficulty_hbox = HBoxContainer.new()
	difficulty_hbox.add_theme_constant_override("separation", 10)
	difficulty_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	difficulty_hbox.offset_top = 300
	
	var difficulties = ["EASY", "NORMAL", "HARD"]
	for i in range(difficulties.size()):
		var btn = Button.new()
		btn.text = difficulties[i]
		btn.custom_minimum_size = Vector2(150, 60)
		btn.pressed.connect(_on_difficulty_selected.bindv([i]))
		difficulty_buttons.append(btn)
		difficulty_hbox.add_child(btn)
	
	add_child(difficulty_hbox)
	
	start_button = Button.new()
	start_button.text = "START BATTLE"
	start_button.custom_minimum_size = Vector2(300, 60)
	start_button.offset_top = 450
	start_button.offset_left = (get_viewport_rect().size.x - 300) / 2
	start_button.pressed.connect(_on_start_pressed)
	start_button.disabled = true
	add_child(start_button)

func _on_arena_selected(arena: String) -> void:
	selected_arena = arena
	start_button.disabled = false
	for i in range(arena_buttons.size()):
		if arenas[i] == arena:
			arena_buttons[i].modulate = Color.YELLOW
		else:
			arena_buttons[i].modulate = Color.WHITE

func _on_difficulty_selected(difficulty: int) -> void:
	selected_difficulty = difficulty
	for i in range(difficulty_buttons.size()):
		if i == difficulty:
			difficulty_buttons[i].modulate = Color.YELLOW
		else:
			difficulty_buttons[i].modulate = Color.WHITE

func _on_start_pressed() -> void:
	if selected_arena != "":
		var player_char = GameManager.player_character
		var opponent = select_opponent(player_char)
		GameManager.start_battle(player_char, opponent, selected_arena, selected_difficulty)

func select_opponent(player_character: String) -> String:
	var male_chars = ["knight_male", "assassin_male", "mage_male"]
	var female_chars = ["knight_female", "assassin_female", "mage_female"]
	
	var available: Array[String] = []
	if player_character in male_chars:
		available = female_chars
	else:
		available = male_chars
	
	return available[randi() % available.size()]
