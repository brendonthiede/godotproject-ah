extends Node3D

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("ui_right"):
		rotation.y += 2 * delta
	if Input.is_action_pressed("ui_left"):
		rotation.y -= 2 * delta
	if Input.is_action_pressed("ui_down"):
		rotation.y = 0
