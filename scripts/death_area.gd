extends Area3D

func _on_body_entered(_player1: Node3D) -> void:
	call_deferred("_reload_game")
	
func _reload_game() -> void:
	get_tree().reload_current_scene()
