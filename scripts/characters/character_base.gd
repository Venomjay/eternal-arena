extends CharacterBody2D

# Base Character Class - Template for all playable characters
# Handles movement, combat, and state management

class_name CharacterBase

# References
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Character Stats
@export var character_name: String = ""
@export var max_health: float = 100.0
@export var max_mana: float = 100.0
@export var move_speed: float = 200.0
@export var dash_speed: float = 500.0
@export var jump_force: float = -400.0
@export var gravity: float = 800.0

# Combat Stats
@export var attack_damage: float = 10.0
@export var heavy_attack_damage: float = 20.0
@export var magic_damage: float = 15.0
@export var crit_chance: float = 0.1
@export var crit_multiplier: float = 1.5

# Current Stats
var health: float
var mana: float
var ultimate_meter: float = 0.0
var max_ultimate: float = 100.0

# State
var is_alive: bool = true
var is_attacking: bool = false
var is_blocking: bool = false
var is_dashing: bool = false
var is_jumping: bool = false
var combo_count: int = 0
var combo_timer: float = 0.0
var combo_timeout: float = 2.0

# Direction
var direction: Vector2 = Vector2.ZERO
var facing_right: bool = true

# Cooldowns
var attack_cooldown: float = 0.0
var dash_cooldown: float = 0.0
var mana_regen_rate: float = 20.0

# Signals
signal health_changed(new_health)
signal mana_changed(new_mana)
signal ultimate_meter_changed(new_ultimate)
signal combo_updated(combo_count, total_damage)
signal character_defeated

func _ready() -> void:
	health = max_health
	mana = max_mana
	set_physics_process(true)

func _physics_process(delta: float) -> void:
	if not is_alive:
		return
	
	handle_input()
	apply_gravity(delta)
	handle_movement(delta)
	handle_cooldowns(delta)
	handle_mana_regen(delta)
	move_and_slide()
	update_animation()

# INPUT HANDLING
func handle_input() -> void:
	direction = Vector2.ZERO
	
	if Input.is_action_pressed("move_left"):
		direction.x = -1
		set_facing_direction(false)
	
	if Input.is_action_pressed("move_right"):
		direction.x = 1
		set_facing_direction(true)
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_force
		is_jumping = true
	
	if Input.is_action_just_pressed("dash") and dash_cooldown <= 0:
		perform_dash()
	
	if Input.is_action_pressed("block"):
		start_blocking()
	else:
		stop_blocking()
	
	# Attack inputs
	if Input.is_action_just_pressed("quick_attack"):
		perform_quick_attack()
	
	if Input.is_action_just_pressed("heavy_attack"):
		perform_heavy_attack()
	
	if Input.is_action_just_pressed("magic_attack"):
		perform_magic_attack()
	
	if Input.is_action_just_pressed("ultimate") and ultimate_meter >= max_ultimate:
		perform_ultimate()

# MOVEMENT
func handle_movement(delta: float) -> void:
	if direction.x != 0:
		velocity.x = direction.x * move_speed
	else:
		velocity.x = move_toward(velocity.x, 0, move_speed * 2 * delta)

func set_facing_direction(right: bool) -> void:
	facing_right = right
	if sprite:
		sprite.flip_h = not right

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

func perform_dash() -> void:
	if is_dashing:
		return
	
	is_dashing = true
	dash_cooldown = 1.0
	var dash_direction = 1 if facing_right else -1
	velocity.x = dash_direction * dash_speed
	
	play_animation("dash")
	
	await get_tree().create_timer(0.3).timeout
	is_dashing = false

# COMBAT
func perform_quick_attack() -> void:
	if is_attacking or attack_cooldown > 0:
		return
	
	is_attacking = true
	attack_cooldown = 0.5
	
	play_animation("quick_attack")
	add_ultimate_meter(5)
	combo_count += 1
	combo_timer = combo_timeout
	
	var damage = calculate_damage(attack_damage)
	signal_attack(damage, "quick")
	
	await get_tree().create_timer(0.4).timeout
	is_attacking = false

func perform_heavy_attack() -> void:
	if is_attacking or attack_cooldown > 0:
		return
	
	is_attacking = true
	attack_cooldown = 1.0
	
	play_animation("heavy_attack")
	add_ultimate_meter(10)
	combo_count += 1
	combo_timer = combo_timeout
	
	var damage = calculate_damage(heavy_attack_damage)
	signal_attack(damage, "heavy")
	
	await get_tree().create_timer(0.6).timeout
	is_attacking = false

func perform_magic_attack() -> void:
	if is_attacking or mana < 20:
		return
	
	is_attacking = true
	attack_cooldown = 0.7
	mana -= 20
	emit_signal("mana_changed", mana)
	
	play_animation("magic_attack")
	add_ultimate_meter(8)
	
	var damage = calculate_damage(magic_damage)
	signal_attack(damage, "magic")
	
	await get_tree().create_timer(0.5).timeout
	is_attacking = false

func perform_ultimate() -> void:
	if ultimate_meter < max_ultimate:
		return
	
	ultimate_meter = 0
	emit_signal("ultimate_meter_changed", ultimate_meter)
	
	is_attacking = true
	
	play_animation("ultimate")
	
	var damage = calculate_damage(heavy_attack_damage * 3)
	signal_attack(damage, "ultimate")
	
	await get_tree().create_timer(1.5).timeout
	is_attacking = false

func start_blocking() -> void:
	is_blocking = true
	play_animation("block")

func stop_blocking() -> void:
	is_blocking = false

# DAMAGE CALCULATION
func calculate_damage(base_damage: float) -> float:
	var damage = base_damage
	
	if randf() < crit_chance:
		damage *= crit_multiplier
		# TODO: Add crit effect
	
	if combo_count > 1:
		damage *= (1.0 + (combo_count * 0.1))  # 10% per combo
	
	return damage

func take_damage(damage: float) -> void:
	if is_blocking:
		damage *= 0.5  # 50% damage reduction while blocking
	
	health -= damage
	emit_signal("health_changed", health)
	
	play_animation("hit")
	
	# TODO: Add hit effect, knockback, etc.
	
	if health <= 0:
		die()

func heal(amount: float) -> void:
	health = min(health + amount, max_health)
	emit_signal("health_changed", health)

# ULTIMATE METER
func add_ultimate_meter(amount: float) -> void:
	ultimate_meter = min(ultimate_meter + amount, max_ultimate)
	emit_signal("ultimate_meter_changed", ultimate_meter)

# MANA
func handle_mana_regen(delta: float) -> void:
	if not is_blocking:
		mana = min(mana + (mana_regen_rate * delta), max_mana)
		emit_signal("mana_changed", mana)

# STATE
func die() -> void:
	is_alive = false
	play_animation("defeat")
	emit_signal("character_defeated")
	set_physics_process(false)

# ANIMATION
func play_animation(anim_name: String) -> void:
	if animation_player:
		animation_player.play(anim_name)

func update_animation() -> void:
	if is_attacking:
		return
	
	if not is_on_floor():
		play_animation("jump")
	elif direction.x != 0:
		play_animation("run")
	else:
		play_animation("idle")

# UTILITY
func signal_attack(damage: float, attack_type: String) -> void:
	# This will be connected to combat manager
	pass

func get_character_info() -> Dictionary:
	return {
		"name": character_name,
		"health": health,
		"max_health": max_health,
		"mana": mana,
		"max_mana": max_mana,
		"ultimate_meter": ultimate_meter,
		"combo_count": combo_count,
		"is_alive": is_alive
	}
