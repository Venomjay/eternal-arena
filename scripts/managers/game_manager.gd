extends Node

# Game Manager - Central hub for game state and logic
# Handles game modes, scene transitions, and global configuration

class_name GameManager

# Game States
enum GameState {
	MENU,
	CHARACTER_SELECT,
	ARENA_SELECT,
	BATTLE,
	PAUSE,
	VICTORY,
	DEFEAT,
	LOADING
}

# Audio Managers
@export var master_volume: float = 1.0
@export var music_volume: float = 0.8
@export var sfx_volume: float = 0.9

# Game State
var current_state: GameState = GameState.MENU
var is_paused: bool = false

# Current Battle Data
var player_character: String = ""
var opponent_character: String = ""
var arena: String = ""
var difficulty: int = 1  # 0 = Easy, 1 = Normal, 2 = Hard

# Player Progress
var player_gold: int = 0
var player_gems: int = 0
var player_experience: int = 0
var unlocked_characters: Array[String] = []
var unlocked_arenas: Array[String] = []

func _ready():
	set_process_input(true)
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)
	update_volumes()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()

# STATE MANAGEMENT
func change_state(new_state: GameState) -> void:
	current_state = new_state
	match new_state:
		GameState.MENU:
			get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")
		GameState.CHARACTER_SELECT:
			get_tree().change_scene_to_file("res://scenes/character_selection/character_selection.tscn")
		GameState.ARENA_SELECT:
			get_tree().change_scene_to_file("res://scenes/arena_selection/arena_selection.tscn")
		GameState.BATTLE:
			get_tree().change_scene_to_file("res://scenes/battle/battle.tscn")
		GameState.PAUSE:
			is_paused = true
			get_tree().paused = true
			get_tree().call_group("pause_overlay", "show")
		GameState.VICTORY:
			get_tree().change_scene_to_file("res://scenes/result_screens/victory_screen.tscn")
		GameState.DEFEAT:
			get_tree().change_scene_to_file("res://scenes/result_screens/defeat_screen.tscn")
		GameState.LOADING:
			get_tree().change_scene_to_file("res://scenes/loading/loading_screen.tscn")

func toggle_pause() -> void:
	if current_state == GameState.BATTLE:
		if is_paused:
			resume_game()
		else:
			pause_game()

func pause_game() -> void:
	is_paused = true
	get_tree().paused = true

func resume_game() -> void:
	is_paused = false
	get_tree().paused = false

# BATTLE SETUP
func start_battle(player: String, opponent: String, arena_name: String, difficulty_level: int) -> void:
	player_character = player
	opponent_character = opponent
	arena = arena_name
	difficulty = difficulty_level
	change_state(GameState.LOADING)
	await get_tree().create_timer(1.0).timeout
	change_state(GameState.BATTLE)

func end_battle_victory() -> void:
	award_battle_rewards()
	change_state(GameState.VICTORY)

func end_battle_defeat() -> void:
	change_state(GameState.DEFEAT)

# PROGRESSION
func award_battle_rewards() -> void:
	var gold_reward: int = 100 + (difficulty * 50)
	var exp_reward: int = 50 + (difficulty * 25)
	
	player_gold += gold_reward
	player_experience += exp_reward
	
	if player_experience >= 1000:
		level_up()

func level_up() -> void:
	player_experience -= 1000
	player_gems += 10

# VOLUME CONTROL
func update_volumes() -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear2db(master_volume))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear2db(music_volume))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear2db(sfx_volume))

func set_master_volume(value: float) -> void:
	master_volume = clamp(value, 0.0, 1.0)
	update_volumes()

func set_music_volume(value: float) -> void:
	music_volume = clamp(value, 0.0, 1.0)
	update_volumes()

func set_sfx_volume(value: float) -> void:
	sfx_volume = clamp(value, 0.0, 1.0)
	update_volumes()

# UTILITY
func get_character_data(character_name: String) -> Dictionary:
	# Load character data from JSON/resource file
	var file_path = "res://data/characters/" + character_name.to_lower() + ".json"
	if ResourceLoader.exists(file_path):
		var file = FileAccess.open(file_path, FileAccess.READ)
		return JSON.parse_string(file.get_as_text())
	return {}

func get_arena_data(arena_name: String) -> Dictionary:
	# Load arena data from JSON/resource file
	var file_path = "res://data/arenas/" + arena_name.to_lower() + ".json"
	if ResourceLoader.exists(file_path):
		var file = FileAccess.open(file_path, FileAccess.READ)
		return JSON.parse_string(file.get_as_text())
	return {}

func is_autoload() -> bool:
	return get_parent() == get_tree().root
