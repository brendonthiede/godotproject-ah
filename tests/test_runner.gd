extends SceneTree

const TEST_DIR := "res://tests"

func _initialize() -> void:
	var suite_paths: Array[String] = _discover_suite_paths()
	var total_tests: int = 0
	var failed_tests: int = 0

	for suite_path in suite_paths:
		var suite_script: GDScript = load(suite_path)
		var test_names: Array[String] = _discover_test_names(suite_script)
		for test_name in test_names:
			total_tests += 1
			var suite: RefCounted = suite_script.new()
			if suite.has_method("before_each"):
				suite.call("before_each")
			suite.call(test_name)
			var failures: PackedStringArray = suite.call("get_failures")
			if failures.is_empty():
				print("[PASS] %s.%s" % [suite_path.get_file().get_basename(), test_name])
			else:
				failed_tests += 1
				printerr("[FAIL] %s.%s" % [suite_path.get_file().get_basename(), test_name])
				for failure in failures:
					printerr("  %s" % failure)
			if suite.has_method("after_each"):
				suite.call("after_each")

	if failed_tests == 0:
		print("All %d tests passed." % total_tests)
	else:
		printerr("%d of %d tests failed." % [failed_tests, total_tests])

	quit(0 if failed_tests == 0 else 1)

func _discover_suite_paths() -> Array[String]:
	var suite_paths: Array[String] = []
	for file_name in DirAccess.get_files_at(TEST_DIR):
		if file_name.ends_with("_test.gd"):
			suite_paths.append("%s/%s" % [TEST_DIR, file_name])
	suite_paths.sort()
	return suite_paths

func _discover_test_names(suite_script: GDScript) -> Array[String]:
	var suite: RefCounted = suite_script.new()
	var test_names: Array[String] = []
	for method_info in suite.get_method_list():
		var method_name: String = method_info.name
		if method_name.begins_with("test_"):
			test_names.append(method_name)
	test_names.sort()
	return test_names