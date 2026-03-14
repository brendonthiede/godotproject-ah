extends CharacterBody3D

const SPEED: float = 7.0
const JUMP_VELOCITY: float = 10.0
const BASE_GRAVITY_MULTIPLIER: float = 3.0
const FALL_MULTIPLIER: float = 5.0
const LOW_JUMP_MULTIPLIER: float = 6.0

var sprint_speed_x: float = 0.0
var sprint_speed_z: float = 0.0

func _physics_process(delta: float) -> void:
	var horizontal_velocity_x: float = 0.0
	var horizontal_velocity_z: float = 0.0

	if Input.is_action_pressed("s"):
		horizontal_velocity_x -= SPEED
	if Input.is_action_pressed("w"):
		horizontal_velocity_x += SPEED
	if Input.is_action_pressed("a"):
		horizontal_velocity_z -= SPEED
	if Input.is_action_pressed("d"):
		horizontal_velocity_z += SPEED
		
	if Input.is_action_pressed("shift"):
		if Input.is_action_pressed("w"):
			if sprint_speed_x < 0:
				sprint_speed_x += 12 * delta
			sprint_speed_x += 10 * delta
			sprint_speed_x = min(sprint_speed_x, 20.0)
			horizontal_velocity_x += sprint_speed_x
		elif Input.is_action_pressed("s"):
			if sprint_speed_x > 0:
				sprint_speed_x -= 12 * delta
			sprint_speed_x -= 10 * delta
			sprint_speed_x = max(sprint_speed_x, -20.0)
			horizontal_velocity_x += sprint_speed_x
		else:
			if sprint_speed_x > 0:
				sprint_speed_x -= 40 * delta
				sprint_speed_x = max(sprint_speed_x, 0.0)
			if sprint_speed_x < 0:
				sprint_speed_x += 40 * delta
				sprint_speed_x = min(sprint_speed_x, 0.0)
			
		if Input.is_action_pressed("d"):
			if sprint_speed_z < 0:
				sprint_speed_z += 12 * delta
			sprint_speed_z += 10 * delta
			sprint_speed_z = min(sprint_speed_z, 20.0)
			horizontal_velocity_z += sprint_speed_z
		elif Input.is_action_pressed("a"):
			if sprint_speed_z > 0:
				sprint_speed_z -= 12 * delta
			sprint_speed_z -= 10 * delta
			sprint_speed_z = max(sprint_speed_z, -20.0)
			horizontal_velocity_z += sprint_speed_z
		else:
			if sprint_speed_z > 0:
				sprint_speed_z -= 40 * delta
				sprint_speed_z = max(sprint_speed_z, 0.0)
			if sprint_speed_z < 0:
				sprint_speed_z += 40 * delta
				sprint_speed_z = min(sprint_speed_z, 0.0)

	velocity.x = horizontal_velocity_x
	velocity.z = horizontal_velocity_z
				
	if not is_on_floor():
		var gravity: Vector3 = get_gravity()
		if velocity.y < 0.0:
			velocity += gravity * FALL_MULTIPLIER * delta
		elif velocity.y > 0.0 and not Input.is_action_pressed("jump"):
			velocity += gravity * LOW_JUMP_MULTIPLIER * delta
		else:
			velocity += gravity * BASE_GRAVITY_MULTIPLIER * delta
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	move_and_slide()
