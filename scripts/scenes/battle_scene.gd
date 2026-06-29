extends Node2D

class_name BattleScene

@onready var camera: Camera2D
var player: CharacterBase
var opponent: CharacterBase
var combat_manager: CombatManager
var hud: HUD
var arena_data: Dictionary

func _ready() -> void:
	setup_scene()

func setup_scene() -> void:
	camera = Camera2D.new()
	camera.zoom = Vector2(0.5, 0.5)
	add_child(camera)
	
	arena_data = GameManager.get_arena_data(GameManager.arena)
	
	player = create_character(GameManager.player_character, Vector2(400, 500))
	player.add_to_group("player")
	add_child(player)
	
	opponent = create_character(GameManager.opponent_character, Vector2(1500, 500))
	opponent.add_to_group("opponent")
	var ai_controller = AIController.new()
	ai_controller.difficulty = GameManager.difficulty
	opponent.add_child(ai_controller)
	add_child(opponent)
	
	combat_manager = CombatManager.new()
	combat_manager.add_to_group("combat_manager")
	add_child(combat_manager)
	
	hud = HUD.new()
	add_child(hud)

func create_character(character_name: String, position: Vector2) -> CharacterBase:
	var char_data = GameManager.get_character_data(character_name)
	var character = CharacterBase.new()
	character.character_name = char_data.get("name", character_name)
	character.max_health = char_data.get("stats", {}).get("max_health", 100)
	character.max_mana = char_data.get("stats", {}).get("max_mana", 100)
	character.move_speed = char_data.get("stats", {}).get("move_speed", 200)
	character.dash_speed = char_data.get("stats", {}).get("dash_speed", 500)
	character.attack_damage = char_data.get("stats", {}).get("attack_damage", 10)
	character.heavy_attack_damage = char_data.get("stats", {}).get("heavy_attack_damage", 20)
	character.magic_damage = char_data.get("stats", {}).get("magic_damage", 15)
	character.crit_chance = char_data.get("stats", {}).get("crit_chance", 0.1)
	character.crit_multiplier = char_data.get("stats", {}).get("crit_multiplier", 1.5)
	character.global_position = position
	return character

func _process(delta: float) -> void:
	if player and opponent:
		var mid_point = (player.global_position + opponent.global_position) / 2
		camera.global_position = mid_point
