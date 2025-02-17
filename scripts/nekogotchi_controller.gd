extends Node3D

@export var buttons: Array[Node3D]
var tween_a: Tween
var tween_b: Tween
var tween_c: Tween

signal button_a_pressed
signal button_b_pressed
signal button_c_pressed

var is_battery_holder_removed: bool = false
@export var battery_holder: Node3D

var battery_holder_tween: Tween
var battery_holder_click_count: int = 0

signal battery_holder_removed


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("tama_button_a"):
		button_press(0)
	if event.is_action_pressed("tama_button_b"):
		button_press(1)
	if event.is_action_pressed("tama_button_c"):
		button_press(2)
	if is_battery_holder_removed:
		return
	if event.is_action_pressed("ui_accept"):
		battery_holder_removing()
	elif event.is_action_released("ui_accept"):
		battery_holder_cancel()

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


func battery_holder_removing() -> void:
	if is_battery_holder_removed:
		return
	if battery_holder_click_count < 4:
		battery_holder_click_count += 1
		if battery_holder_tween:
			battery_holder_tween.kill()
			battery_holder.position.y = 0
		battery_holder_tween = get_tree().create_tween().set_loops()
		battery_holder_tween.tween_property(battery_holder, "position:y", 0.01, 0.05)
		battery_holder_tween.tween_property(battery_holder, "position:y", -0.01, 0.05)
	else:
		is_battery_holder_removed = true
		if battery_holder_tween:
			battery_holder_tween.kill()
			battery_holder.position.y = 0
		battery_holder_tween = get_tree().create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
		await battery_holder_tween.tween_property(battery_holder, "position:x", 15.0, 0.6).finished
		battery_holder.visible = false
		battery_holder_removed.emit()

func battery_holder_cancel() -> void:
	if is_battery_holder_removed:
		return
	if battery_holder_tween:
		battery_holder_tween.kill()
		battery_holder.position.y = 0

func battery_holder_input_event(_camera: Node, event: InputEvent, _event_position: Vector3 = Vector3.ZERO, _normal: Vector3 = Vector3.ZERO, _shape_idx: int = 0) -> void:
	if is_battery_holder_removed:
		return
	if event is InputEventMouseButton and event.is_pressed():
		battery_holder_removing()
	elif event is InputEventMouseButton and !event.is_pressed():
		battery_holder_cancel()
