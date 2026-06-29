extends Node

# AI Controller - Manages opponent AI behavior and decision-making

class_name AIController

# References
var character: CharacterBase
var player: CharacterBase

# Difficulty Settings
@export var difficulty: int = 1  # 0 = Easy, 1 = Normal, 2 = Hard
@export var reaction_time_range: Vector2 = Vector2(0.3, 0.8)  # Easy to Hard

# AI State
var state: String = "idle"
var state_timer: float = 0.0
var last_action_time: float = 0.0
var action_cooldown: float = 0.5

# Decision Making
var awareness_range: float = 500.0
var attack_probability: float = 0.6
var block_probability: float = 0.4
var dash_probability: float = 0.3

# Behavior Patterns
var aggressive_threshold: float = 0.7  # Health percentage
var defensive_threshold: float = 0.3   # Health percentage
var use_ultimate_threshold: float = 0.5  # Health percentage

# Signals
signal action_performed(action_type)

func _ready() -> void:
	character = get_parent()
	player = get_tree().get_first_node_in_group("player")
	
	if not character or not player:
		queue_free()
		return
	
	set_process(true)

func _process(delta: float) -> void:
	update_state(delta)
	make_decision(delta)

# STATE MANAGEMENT
func update_state(delta: float) -> void:
	state_timer -= delta
	last_action_time += delta
	
	# Distance to player
	var distance = character.global_position.distance_to(player.global_position)
	
	if distance < awareness_range and player.is_alive:
		state = "combat"
	else:
		state = "idle"

# DECISION MAKING
func make_decision(delta: float) -> void:
	if state == "idle":
		return
	
	if last_action_time < action_cooldown:
		return
	
	var character_health_ratio = character.health / character.max_health
	var distance = character.global_position.distance_to(player.global_position)
	
	# Ultimate ability
	if character.ultimate_meter >= character.max_ultimate:
		if character_health_ratio < use_ultimate_threshold:
			perform_ultimate()
			return
	
	# Defensive play at low health
	if character_health_ratio < defensive_threshold:
		if randf() < block_probability * difficulty_modifier():
			perform_block()
		else:
			perform_dash_away()
		return
	
	# Aggressive play at high health
	if character_health_ratio > aggressive_threshold:
		if randf() < attack_probability:
			choose_attack(distance)
			return
	
	# Normal behavior
	var rand = randf()
	if rand < 0.4 * difficulty_modifier():
		choose_attack(distance)
	elif rand < 0.6:
		move_toward_player(distance)
	else:
		perform_defensive_action()

# ATTACK SELECTION
func choose_attack(distance: float) -> void:
	var rand = randf()
	
	if distance > 200:
		# Use magic attacks at range
		if character.mana > 20 and randf() < 0.6:
			perform_magic_attack()
		else:
			perform_quick_attack()
	else:
		# Combo at close range
		if rand < 0.4:
			perform_quick_attack()
		elif rand < 0.7:
			perform_heavy_attack()
		else:
			perform_magic_attack()

# ACTION EXECUTION
func perform_quick_attack() -> void:
	character.perform_quick_attack()
	last_action_time = 0.0
	emit_signal("action_performed", "quick_attack")

func perform_heavy_attack() -> void:
	character.perform_heavy_attack()
	last_action_time = 0.0
	emit_signal("action_performed", "heavy_attack")

func perform_magic_attack() -> void:
	character.perform_magic_attack()
	last_action_time = 0.0
	emit_signal("action_performed", "magic_attack")

func perform_ultimate() -> void:
	character.perform_ultimate()
	last_action_time = 0.0
	emit_signal("action_performed", "ultimate")

func perform_block() -> void:
	character.start_blocking()
	await get_tree().create_timer(0.5).timeout
	character.stop_blocking()
	last_action_time = 0.0
	emit_signal("action_performed", "block")

func perform_dash_away() -> void:
	character.direction.x = -1 if character.facing_right else 1
	character.perform_dash()
	last_action_time = 0.0
	emit_signal("action_performed", "dash_away")

func move_toward_player(distance: float) -> void:
	if distance > 100:
		var direction = sign(player.global_position.x - character.global_position.x)
		character.direction.x = direction
		character.set_facing_direction(direction > 0)

func perform_defensive_action() -> void:
	if randf() < 0.5:
		perform_block()
	else:
		perform_dash_away()

# DIFFICULTY MODIFIERS
func difficulty_modifier() -> float:
	match difficulty:
		0:  # Easy
			return 0.5
		1:  # Normal
			return 1.0
		2:  # Hard
			return 1.5
		_:
			return 1.0

# Reaction time based on difficulty
func get_reaction_time() -> float:
	var base = randf_range(reaction_time_range.x, reaction_time_range.y)
	return base / difficulty_modifier()
