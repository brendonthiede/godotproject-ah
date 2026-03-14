extends CharacterBody3D

const SPEED: float = 7.0
const JUMP_VELOCITY: float = 100.0

var sprint_speed_x: float = 0.0
var sprint_speed_z: float = 0.0

func _physics_process(delta: float) -> void:
	
	if Input.is_action_pressed("s"):
		position.x -= SPEED * delta
	if Input.is_action_pressed("w"):
		position.x += SPEED * delta
	if Input.is_action_pressed("a"):
		position.z -= SPEED * delta
	if Input.is_action_pressed("d"):
		position.z += SPEED * delta
		
	if Input.is_action_pressed("shift"):
		if Input.is_action_pressed("w"):
			if sprint_speed_x < 0:
				sprint_speed_x += 12 * delta
			sprint_speed_x += 10 * delta
			sprint_speed_x = min(sprint_speed_x, 20.0)
			position.x += sprint_speed_x * delta
		elif Input.is_action_pressed("s"):
			if sprint_speed_x > 0:
				sprint_speed_x -= 12 * delta
			sprint_speed_x -= 10 * delta
			sprint_speed_x = max(sprint_speed_x, -20.0)
			position.x += sprint_speed_x * delta
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
			position.z += sprint_speed_z * delta
		elif Input.is_action_pressed("a"):
			if sprint_speed_z > 0:
				sprint_speed_z -= 12 * delta
			sprint_speed_z -= 10 * delta
			sprint_speed_z = max(sprint_speed_z, -20.0)
			position.z += sprint_speed_z * delta
		else:
			if sprint_speed_z > 0:
				sprint_speed_z -= 40 * delta
				sprint_speed_z = max(sprint_speed_z, 0.0)
			if sprint_speed_z < 0:
				sprint_speed_z += 40 * delta
				sprint_speed_z = min(sprint_speed_z, 0.0)
				
	if not is_on_floor():
		velocity += get_gravity() * 4 * delta
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		velocity.y = max(position.y, 10.0)
	move_and_slide()
