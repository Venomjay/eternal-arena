extends CanvasLayer

# HUD - Heads Up Display for battle information

class_name HUD

# References
@onready var player_health_bar: ProgressBar = $VBoxContainer/PlayerStats/HealthBar
@onready var player_mana_bar: ProgressBar = $VBoxContainer/PlayerStats/ManaBar
@onready var player_ultimate_bar: ProgressBar = $VBoxContainer/PlayerStats/UltimateBar
@onready var opponent_health_bar: ProgressBar = $VBoxContainer/OpponentStats/HealthBar
@onready var timer_label: Label = $VBoxContainer/CenterContainer/TimerLabel
@onready var combo_label: Label = $VBoxContainer/PlayerStats/ComboLabel

var player: CharacterBase
var opponent: CharacterBase
var combat_manager: CombatManager

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	opponent = get_tree().get_first_node_in_group("opponent")
	combat_manager = get_tree().get_first_node_in_group("combat_manager")
	
	if player:
		player.health_changed.connect(_on_player_health_changed)
		player.mana_changed.connect(_on_player_mana_changed)
		player.ultimate_meter_changed.connect(_on_player_ultimate_changed)
		player.combo_updated.connect(_on_player_combo_updated)
		
		update_player_health_bar()
		update_player_mana_bar()
		update_player_ultimate_bar()
	
	if opponent:
		opponent.health_changed.connect(_on_opponent_health_changed)
		update_opponent_health_bar()
	
	if combat_manager:
		combat_manager.match_time_updated.connect(_on_match_time_updated)
	
	set_process(true)

func _process(delta: float) -> void:
	if combat_manager:
		update_timer()

# PLAYER STATS
func _on_player_health_changed(new_health: float) -> void:
	update_player_health_bar()

func _on_player_mana_changed(new_mana: float) -> void:
	update_player_mana_bar()

func _on_player_ultimate_changed(new_ultimate: float) -> void:
	update_player_ultimate_bar()

func _on_player_combo_updated(combo_count: int, total_damage: float) -> void:
	if combo_label:
		if combo_count > 1:
			combo_label.text = "COMBO x%d" % combo_count
			combo_label.show()
		else:
			combo_label.hide()

# OPPONENT STATS
func _on_opponent_health_changed(new_health: float) -> void:
	update_opponent_health_bar()

# TIMER
func _on_match_time_updated(time_remaining: float) -> void:
	pass  # Update handled in _process

func update_timer() -> void:
	if timer_label and combat_manager:
		var time_remaining = combat_manager.get_match_time_remaining()
		timer_label.text = combat_manager.format_time(time_remaining)

# UPDATE FUNCTIONS
func update_player_health_bar() -> void:
	if player_health_bar and player:
		player_health_bar.max_value = player.max_health
		player_health_bar.value = player.health

func update_player_mana_bar() -> void:
	if player_mana_bar and player:
		player_mana_bar.max_value = player.max_mana
		player_mana_bar.value = player.mana

func update_player_ultimate_bar() -> void:
	if player_ultimate_bar and player:
		player_ultimate_bar.max_value = player.max_ultimate
		player_ultimate_bar.value = player.ultimate_meter

func update_opponent_health_bar() -> void:
	if opponent_health_bar and opponent:
		opponent_health_bar.max_value = opponent.max_health
		opponent_health_bar.value = opponent.health
