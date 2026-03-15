extends "res://tests/test_case.gd"

const PlayerControllerScript := preload("res://scripts/player_controller.gd")

class ControllerDouble:
	extends PlayerControllerScript

	var pressed_actions: Dictionary = {}
	var just_pressed_actions: Dictionary = {}
	var on_floor_override: bool = true
	var gravity_override: Vector3 = Vector3(0.0, -9.8, 0.0)
	var move_calls: int = 0

	func _is_action_pressed(action: StringName) -> bool:
		return pressed_actions.get(action, false)

	func _is_action_just_pressed(action: StringName) -> bool:
		return just_pressed_actions.get(action, false)

	func _is_player_on_floor() -> bool:
		return on_floor_override

	func _get_player_gravity() -> Vector3:
		return gravity_override

	func _move_player() -> void:
		move_calls += 1

var _controllers: Array[ControllerDouble] = []

func _make_controller() -> ControllerDouble:
	var controller := ControllerDouble.new()
	_controllers.append(controller)
	return controller

func after_each() -> void:
	for controller in _controllers:
		controller.free()
	_controllers.clear()

func test_no_input_resets_horizontal_velocity_and_moves_once() -> void:
	var controller := _make_controller()
	controller.velocity = Vector3(3.0, 2.0, -4.0)

	controller._physics_process(0.5)

	assert_vector3_close(
		controller.velocity,
		Vector3(0.0, 2.0, 0.0),
		"No input should zero horizontal velocity while preserving vertical velocity on the floor"
	)
	assert_equal(controller.move_calls, 1, "move_and_slide should be called exactly once per physics tick")

func test_directional_input_sets_horizontal_velocity() -> void:
	var controller := _make_controller()
	controller.pressed_actions = {"w": true, "d": true}

	controller._physics_process(0.5)

	assert_float_close(controller.velocity.x, controller.SPEED, "Forward input should set positive x velocity")
	assert_float_close(controller.velocity.z, controller.SPEED, "Right input should set positive z velocity")

func test_opposite_direction_inputs_cancel_each_other() -> void:
	var controller := _make_controller()
	controller.pressed_actions = {"w": true, "s": true, "a": true, "d": true}

	controller._physics_process(0.5)

	assert_vector3_close(controller.velocity, Vector3.ZERO, "Opposite directional inputs should cancel each horizontal axis")

func test_shift_forward_accelerates_sprint_speed_and_adds_it_to_velocity() -> void:
	var controller := _make_controller()
	controller.pressed_actions = {"shift": true, "w": true}

	controller._physics_process(0.5)

	assert_float_close(controller.sprint_speed_x, 5.0, "Shifting forward should build sprint speed on x")
	assert_float_close(controller.velocity.x, 12.0, "Forward sprint should add sprint speed to base forward speed")

func test_shift_forward_reverses_negative_sprint_before_accelerating() -> void:
	var controller := _make_controller()
	controller.pressed_actions = {"shift": true, "w": true}
	controller.sprint_speed_x = -4.0

	controller._physics_process(0.5)

	assert_float_close(controller.sprint_speed_x, 7.0, "Forward sprint should first undo backward sprint, then accelerate")
	assert_float_close(controller.velocity.x, 14.0, "Forward sprint should add the updated sprint speed after reversing direction")

func test_shift_only_brakes_positive_x_sprint_toward_zero() -> void:
	var controller := _make_controller()
	controller.pressed_actions = {"shift": true}
	controller.sprint_speed_x = 5.0

	controller._physics_process(0.1)

	assert_float_close(controller.sprint_speed_x, 1.0, "Holding shift without forward or back should brake positive x sprint speed")
	assert_float_close(controller.velocity.x, 0.0, "Braking x sprint should not add horizontal movement on its own")

func test_shift_right_accelerates_z_sprint_speed_and_adds_it_to_velocity() -> void:
	var controller := _make_controller()
	controller.pressed_actions = {"shift": true, "d": true}

	controller._physics_process(0.5)

	assert_float_close(controller.sprint_speed_z, 5.0, "Shifting right should build sprint speed on z")
	assert_float_close(controller.velocity.z, 12.0, "Right sprint should add sprint speed to base right speed")

func test_sprint_speed_is_not_applied_or_decay_without_shift() -> void:
	var controller := _make_controller()
	controller.pressed_actions = {"w": true}
	controller.sprint_speed_x = 8.0
	controller.sprint_speed_z = -3.0

	controller._physics_process(0.2)

	assert_float_close(controller.velocity.x, controller.SPEED, "Stored sprint speed should not be applied when shift is not pressed")
	assert_float_close(controller.velocity.z, 0.0, "Stored sprint speed should not create strafing without directional input")
	assert_float_close(controller.sprint_speed_x, 8.0, "Stored x sprint speed should remain unchanged when shift is not pressed")
	assert_float_close(controller.sprint_speed_z, -3.0, "Stored z sprint speed should remain unchanged when shift is not pressed")

func test_forward_sprint_speed_is_clamped_to_maximum() -> void:
	var controller := _make_controller()
	controller.pressed_actions = {"shift": true, "w": true}
	controller.sprint_speed_x = 19.0

	controller._physics_process(1.0)

	assert_float_close(controller.sprint_speed_x, 20.0, "Forward sprint speed should clamp at the configured maximum")
	assert_float_close(controller.velocity.x, 27.0, "Forward velocity should use the clamped sprint speed")

func test_airborne_falling_uses_fall_multiplier() -> void:
	var controller := _make_controller()
	controller.on_floor_override = false
	controller.gravity_override = Vector3(0.0, -10.0, 0.0)
	controller.velocity = Vector3(0.0, -1.0, 0.0)

	controller._physics_process(0.5)

	assert_float_close(controller.velocity.y, -26.0, "Falling should apply the fall gravity multiplier")

func test_airborne_rising_without_jump_held_uses_low_jump_multiplier() -> void:
	var controller := _make_controller()
	controller.on_floor_override = false
	controller.gravity_override = Vector3(0.0, -10.0, 0.0)
	controller.velocity = Vector3(0.0, 4.0, 0.0)

	controller._physics_process(0.5)

	assert_float_close(controller.velocity.y, -26.0, "Rising without jump held should apply the low-jump multiplier")

func test_airborne_rising_with_jump_held_uses_base_gravity_multiplier() -> void:
	var controller := _make_controller()
	controller.on_floor_override = false
	controller.gravity_override = Vector3(0.0, -10.0, 0.0)
	controller.velocity = Vector3(0.0, 4.0, 0.0)
	controller.pressed_actions = {"jump": true}

	controller._physics_process(0.5)

	assert_float_close(controller.velocity.y, -11.0, "Rising with jump held should apply the base gravity multiplier")

func test_airborne_zero_vertical_velocity_uses_base_gravity_multiplier() -> void:
	var controller := _make_controller()
	controller.on_floor_override = false
	controller.gravity_override = Vector3(0.0, -10.0, 0.0)
	controller.velocity = Vector3.ZERO

	controller._physics_process(0.5)

	assert_float_close(controller.velocity.y, -15.0, "Zero vertical velocity in air should use the base gravity multiplier")

func test_jump_from_floor_sets_jump_velocity() -> void:
	var controller := _make_controller()
	controller.just_pressed_actions = {"jump": true}
	controller.velocity = Vector3(0.0, 3.0, 0.0)

	controller._physics_process(0.5)

	assert_float_close(controller.velocity.y, controller.JUMP_VELOCITY, "Jumping from the floor should set jump velocity")

func test_jump_just_pressed_in_air_does_not_override_airborne_velocity() -> void:
	var controller := _make_controller()
	controller.on_floor_override = false
	controller.gravity_override = Vector3(0.0, -10.0, 0.0)
	controller.velocity = Vector3(0.0, 4.0, 0.0)
	controller.just_pressed_actions = {"jump": true}
	controller.pressed_actions = {"jump": true}

	controller._physics_process(0.5)

	assert_float_close(controller.velocity.y, -11.0, "Jump just pressed in the air should not set jump velocity")