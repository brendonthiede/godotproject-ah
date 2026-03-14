extends Node3D

func _is_pressed(primary: StringName, fallback: StringName) -> bool:
	return Input.is_action_pressed(primary) or Input.is_action_pressed(fallback)

func _is_just_pressed(primary: StringName, fallback: StringName) -> bool:
	return Input.is_action_just_pressed(primary) or Input.is_action_just_pressed(fallback)

func _physics_process(delta: float) -> void:
	
	if _is_just_pressed("ui_right", "d"):
		rotation.y = 30 * delta
		max(rotation.y, 30)
	if _is_pressed("ui_left", "a"):
		rotation.y = -30 * delta
	if _is_pressed("ui_down", "s"):
		rotation.y = 0 * delta
