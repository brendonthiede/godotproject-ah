extends CharacterBody3D

const SPEED: float = 7.0
const JUMP_VELOCITY: float = 10.0
const BASE_GRAVITY_MULTIPLIER: float = 3.0
const FALL_MULTIPLIER: float = 5.0
const LOW_JUMP_MULTIPLIER: float = 6.0

var sprint_speed_x: float = 0.0
var sprint_speed_z: float = 0.0

func _is_action_pressed(action: StringName) -> bool:
	return Input.is_action_pressed(action)

func _is_action_just_pressed(action: StringName) -> bool:
	return Input.is_action_just_pressed(action)

func _is_player_on_floor() -> bool:
	return is_on_floor()

func _get_player_gravity() -> Vector3:
	return get_gravity()

func _move_player() -> void:
	move_and_slide()

func _get_axis_velocity(positive_action: StringName, negative_action: StringName) -> float:
	var axis_velocity: float = 0.0

	if _is_action_pressed(negative_action):
		axis_velocity -= SPEED
	if _is_action_pressed(positive_action):
		axis_velocity += SPEED

	return axis_velocity

func _get_base_horizontal_velocity() -> Vector2:
	return Vector2(
		_get_axis_velocity("w", "s"),
		_get_axis_velocity("d", "a")
	)

func _apply_sprint_speed(delta: float, horizontal_velocity: float, sprint_speed: float, positive_action: StringName, negative_action: StringName) -> Vector2:
	if _is_action_pressed(positive_action):
		if sprint_speed < 0:
			sprint_speed += 12 * delta
		sprint_speed += 10 * delta
		sprint_speed = min(sprint_speed, 20.0)
		horizontal_velocity += sprint_speed
	elif _is_action_pressed(negative_action):
		if sprint_speed > 0:
			sprint_speed -= 12 * delta
		sprint_speed -= 10 * delta
		sprint_speed = max(sprint_speed, -20.0)
		horizontal_velocity += sprint_speed
	else:
		if sprint_speed > 0:
			sprint_speed -= 40 * delta
			sprint_speed = max(sprint_speed, 0.0)
		if sprint_speed < 0:
			sprint_speed += 40 * delta
			sprint_speed = min(sprint_speed, 0.0)

	return Vector2(sprint_speed, horizontal_velocity)

func _get_horizontal_state(delta: float) -> Dictionary:
	var horizontal_velocity := _get_base_horizontal_velocity()
	var next_sprint_speed_x: float = sprint_speed_x
	var next_sprint_speed_z: float = sprint_speed_z

	if _is_action_pressed("shift"):
		var x_axis_result := _apply_sprint_speed(delta, horizontal_velocity.x, next_sprint_speed_x, "w", "s")
		next_sprint_speed_x = x_axis_result.x
		horizontal_velocity.x = x_axis_result.y

		var z_axis_result := _apply_sprint_speed(delta, horizontal_velocity.y, next_sprint_speed_z, "d", "a")
		next_sprint_speed_z = z_axis_result.x
		horizontal_velocity.y = z_axis_result.y

	return {
		"horizontal_velocity": horizontal_velocity,
		"sprint_speed_x": next_sprint_speed_x,
		"sprint_speed_z": next_sprint_speed_z,
	}

func _get_air_gravity_adjusted_velocity_y(delta: float, velocity_y: float) -> float:
	if _is_player_on_floor():
		return velocity_y

	var gravity: Vector3 = _get_player_gravity()
	if velocity_y < 0.0:
		velocity_y += gravity.y * FALL_MULTIPLIER * delta
	elif velocity_y > 0.0 and not _is_action_pressed("jump"):
		velocity_y += gravity.y * LOW_JUMP_MULTIPLIER * delta
	else:
		velocity_y += gravity.y * BASE_GRAVITY_MULTIPLIER * delta

	return velocity_y

func _get_jump_adjusted_velocity_y(velocity_y: float) -> float:
	if _is_action_just_pressed("jump") and _is_player_on_floor():
		return JUMP_VELOCITY

	return velocity_y

func _get_vertical_state(delta: float) -> Dictionary:
	var velocity_y: float = velocity.y
	velocity_y = _get_air_gravity_adjusted_velocity_y(delta, velocity_y)
	velocity_y = _get_jump_adjusted_velocity_y(velocity_y)

	return {
		"velocity_y": velocity_y,
	}

func _physics_process(delta: float) -> void:
	var horizontal_state := _get_horizontal_state(delta)
	var vertical_state := _get_vertical_state(delta)
	var horizontal_velocity: Vector2 = horizontal_state["horizontal_velocity"]
	var velocity_y: float = vertical_state["velocity_y"]
	sprint_speed_x = horizontal_state["sprint_speed_x"]
	sprint_speed_z = horizontal_state["sprint_speed_z"]

	velocity.x = horizontal_velocity.x
	velocity.y = velocity_y
	velocity.z = horizontal_velocity.y

	_move_player()
