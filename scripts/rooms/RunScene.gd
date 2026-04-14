extends Node2D

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_reset_run()

func _reset_run() -> void:
	Engine.time_scale = 1.0
	get_tree().change_scene_to_file("res://scenes/hub/KernelHub.tscn")
