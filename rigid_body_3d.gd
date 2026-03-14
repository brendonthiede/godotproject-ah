extends RigidBody3D

var velocity = Vector3.ZERO
var speed = 1200
var jump_velocity = 5

func _physics_process(delta: float) -> void:
	var rotation_speed = 2
	var rotation_direction = Input.get_axis("turn_left", "turn_right")
	rotation.y -= rotation_direction * rotation_speed * delta
	
	var rotation_direction1 = Input.get_axis("ui_left", "ui_right")
	rotation.y -= rotation_direction1 * rotation_speed * delta
	
	if Input.is_action_pressed("move_forward"):
		apply_central_force(-transform.basis.z * speed * delta)
	
	# Error at (19, 12): Function "is_on_floor()" not found in base self.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if Input.is_action_just_pressed("jump") and is_on_floor():
		apply_impulse(transform.basis.y * jump_velocity * delta)
	
	
		
