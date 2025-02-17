extends Node3D

@export var buttons: Array[Node3D]
var tween_a: Tween
var tween_b: Tween
var tween_c: Tween

signal button_a_pressed
signal button_b_pressed
signal button_c_pressed

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("tama_button_a"):
		button_press(0)
	if event.is_action_pressed("tama_button_b"):
		button_press(1)
	if event.is_action_pressed("tama_button_c"):
		button_press(2)


func button_press(buttonID: int) -> void:
	match buttonID:
		0:
			if (tween_a):
				tween_a.kill()
			buttons[buttonID].position.y = 0.0
			tween_a = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
			tween_a.tween_property(buttons[buttonID], "position:y", -0.07, 0.1)
			tween_a.tween_property(buttons[buttonID], "position:y", 0.0, 0.1)
			button_a_pressed.emit()
		1:
			if (tween_b):
				tween_b.kill()
			buttons[buttonID].position.y = 0.0
			tween_b = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
			tween_b.tween_property(buttons[buttonID], "position:y", -0.07, 0.1)
			tween_b.tween_property(buttons[buttonID], "position:y", 0.0, 0.1)
			button_b_pressed.emit()
		2:
			if (tween_c):
				tween_c.kill()
			buttons[buttonID].position.y = 0.0
			tween_c = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
			tween_c.tween_property(buttons[buttonID], "position:y", -0.07, 0.1)
			tween_c.tween_property(buttons[buttonID], "position:y", 0.0, 0.1)
			button_c_pressed.emit()

func button_press_3d(_camera: Node, event: InputEvent, _event_position: Vector3 = Vector3.ZERO, _normal: Vector3 = Vector3.ZERO, _shape_idx: int = 0, buttonID: int = 0) -> void:
	if event.is_pressed():
		button_press(buttonID)