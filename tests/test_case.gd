extends RefCounted

var _failures: PackedStringArray = []

func assert_true(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)

func assert_equal(actual: Variant, expected: Variant, message: String) -> void:
	if actual != expected:
		_failures.append("%s expected %s, got %s" % [message, var_to_str(expected), var_to_str(actual)])

func assert_float_close(actual: float, expected: float, message: String, tolerance: float = 0.0001) -> void:
	if absf(actual - expected) > tolerance:
		_failures.append("%s expected %s, got %s" % [message, str(expected), str(actual)])

func assert_vector3_close(actual: Vector3, expected: Vector3, message: String, tolerance: float = 0.0001) -> void:
	if not actual.is_equal_approx(expected):
		var delta: Vector3 = actual - expected
		if absf(delta.x) > tolerance or absf(delta.y) > tolerance or absf(delta.z) > tolerance:
			_failures.append("%s expected %s, got %s" % [message, var_to_str(expected), var_to_str(actual)])

func get_failures() -> PackedStringArray:
	return _failures