extends MeshInstance3D

func _physics_process(_delta: float) -> void:

	if Input.is_action_pressed("w"):
		rotation_degrees.y = 90
	if Input.is_action_pressed("d"):
		rotation_degrees.y = 0
	if Input.is_action_pressed("s"):
		rotation_degrees.y = -90
	if Input.is_action_pressed("a"):
		rotation_degrees.y = 180
	if Input.is_action_pressed("w") and Input.is_action_pressed("a"):
		rotation_degrees.y = 135
	if Input.is_action_pressed("w") and Input.is_action_pressed("d"):
		rotation_degrees.y = 45
	if Input.is_action_pressed("s") and Input.is_action_pressed("d"):
		rotation_degrees.y = -45
	if Input.is_action_pressed("s") and Input.is_action_pressed("a"):
		rotation_degrees.y = -135
