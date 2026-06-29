extends Node

# Input Manager - Centralized input handling and configuration

class_name InputManager

func _ready() -> void:
	setup_input_map()

func setup_input_map() -> void:
	# Movement
	if not InputMap.has_action("move_left"):
		InputMap.add_action("move_left")
		var event = InputEventKey.new()
		event.keycode = KEY_A
		InputMap.action_add_event("move_left", event)
	
	if not InputMap.has_action("move_right"):
		InputMap.add_action("move_right")
		var event = InputEventKey.new()
		event.keycode = KEY_D
		InputMap.action_add_event("move_right", event)
	
	if not InputMap.has_action("jump"):
		InputMap.add_action("jump")
		var event = InputEventKey.new()
		event.keycode = KEY_SPACE
		InputMap.action_add_event("jump", event)
	
	if not InputMap.has_action("dash"):
		InputMap.add_action("dash")
		var event = InputEventKey.new()
		event.keycode = KEY_SHIFT
		InputMap.action_add_event("dash", event)
	
	if not InputMap.has_action("block"):
		InputMap.add_action("block")
		var event = InputEventKey.new()
		event.keycode = KEY_S
		InputMap.action_add_event("block", event)
	
	# Combat
	if not InputMap.has_action("quick_attack"):
		InputMap.add_action("quick_attack")
		var event = InputEventKey.new()
		event.keycode = KEY_J
		InputMap.action_add_event("quick_attack", event)
	
	if not InputMap.has_action("heavy_attack"):
		InputMap.add_action("heavy_attack")
		var event = InputEventKey.new()
		event.keycode = KEY_K
		InputMap.action_add_event("heavy_attack", event)
	
	if not InputMap.has_action("magic_attack"):
		InputMap.add_action("magic_attack")
		var event = InputEventKey.new()
		event.keycode = KEY_L
		InputMap.action_add_event("magic_attack", event)
	
	if not InputMap.has_action("spin_attack"):
		InputMap.add_action("spin_attack")
		var event = InputEventKey.new()
		event.keycode = KEY_U
		InputMap.action_add_event("spin_attack", event)
	
	if not InputMap.has_action("power_strike"):
		InputMap.add_action("power_strike")
		var event = InputEventKey.new()
		event.keycode = KEY_I
		InputMap.action_add_event("power_strike", event)
	
	if not InputMap.has_action("counter"):
		InputMap.add_action("counter")
		var event = InputEventKey.new()
		event.keycode = KEY_O
		InputMap.action_add_event("counter", event)
	
	if not InputMap.has_action("ultimate"):
		InputMap.add_action("ultimate")
		var event = InputEventKey.new()
		event.keycode = KEY_F
		InputMap.action_add_event("ultimate", event)
	
	if not InputMap.has_action("pause"):
		InputMap.add_action("pause")
		var event = InputEventKey.new()
		event.keycode = KEY_ESCAPE
		InputMap.action_add_event("pause", event)
