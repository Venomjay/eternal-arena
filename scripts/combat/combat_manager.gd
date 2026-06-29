extends Node

# Combat Manager - Handles all combat mechanics, hit detection, and combat state

class_name CombatManager

# References
var player: CharacterBase
var opponent: CharacterBase

# Combat State
var is_combat_active: bool = true
var match_time: float = 0.0
var match_duration: float = 300.0  # 5 minutes
var player_combo_damage: float = 0.0
var opponent_combo_damage: float = 0.0

# Signals
signal match_time_updated(time_remaining)
signal player_defeated
signal opponent_defeated
signal hit_registered(damage, hit_position, is_critical)

func _ready() -> void:
	# Get references to player and opponent
	player = get_tree().get_first_node_in_group("player")
	opponent = get_tree().get_first_node_in_group("opponent")
	
	if player and opponent:
		player.health_changed.connect(_on_player_health_changed)
		opponent.health_changed.connect(_on_opponent_health_changed)
	
	set_process(true)

func _process(delta: float) -> void:
	if not is_combat_active:
		return
	
	match_time += delta
	
	if match_time >= match_duration:
		end_match_by_timeout()
	
	emit_signal("match_time_updated", match_duration - match_time)

# ATTACK REGISTRATION
func register_attack(attacker: CharacterBase, target: CharacterBase, damage: float, attack_type: String) -> void:
	if not is_combat_active or not target.is_alive:
		return
	
	var is_critical = randf() < attacker.crit_chance
	var final_damage = damage * (1.5 if is_critical else 1.0)
	
	# Apply damage
	target.take_damage(final_damage)
	
	# Update combo
	if attacker == player:
		player_combo_damage += final_damage
	else:
		opponent_combo_damage += final_damage
	
	# Create hit effect
	create_hit_effect(target.global_position, final_damage, is_critical)
	
	# Screen shake on heavy hits
	if damage > 20:
		apply_screen_shake(0.2, 5)
	
	emit_signal("hit_registered", final_damage, target.global_position, is_critical)

func create_hit_effect(position: Vector2, damage: float, is_critical: bool) -> void:
	# TODO: Instantiate damage number sprite
	# TODO: Add particle effects
	# TODO: Add screen flash if critical
	pass

func apply_screen_shake(intensity: float, duration: float) -> void:
	# TODO: Implement camera shake
	pass

# MATCH STATE
func _on_player_health_changed(new_health: float) -> void:
	if new_health <= 0:
		end_match_player_defeated()

func _on_opponent_health_changed(new_health: float) -> void:
	if new_health <= 0:
		end_match_opponent_defeated()

func end_match_player_defeated() -> void:
	is_combat_active = false
	emit_signal("player_defeated")
	GameManager.end_battle_defeat()

func end_match_opponent_defeated() -> void:
	is_combat_active = false
	emit_signal("opponent_defeated")
	GameManager.end_battle_victory()

func end_match_by_timeout() -> void:
	is_combat_active = false
	
	# Check who has more health
	if player.health > opponent.health:
		emit_signal("opponent_defeated")
		GameManager.end_battle_victory()
	elif opponent.health > player.health:
		emit_signal("player_defeated")
		GameManager.end_battle_defeat()
	else:
		# Draw - depends on victory condition
		emit_signal("opponent_defeated")
		GameManager.end_battle_victory()

# COMBAT QUERIES
func get_player_combo_damage() -> float:
	return player_combo_damage

func get_opponent_combo_damage() -> float:
	return opponent_combo_damage

func reset_player_combo() -> void:
	player_combo_damage = 0.0

func reset_opponent_combo() -> void:
	opponent_combo_damage = 0.0

func get_match_time_remaining() -> float:
	return max(0.0, match_duration - match_time)

func format_time(seconds: float) -> String:
	var minutes = int(seconds) / 60
	var secs = int(seconds) % 60
	return "%02d:%02d" % [minutes, secs]
