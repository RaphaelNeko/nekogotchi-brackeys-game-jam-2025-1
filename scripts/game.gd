extends Node

@export var intro_animation: AnimationPlayer
@export var nekogotchi: Node3D
@export var game_screen: Control

@export var background_overlay: ColorRect

@export var dialogue_intro: DialogueResource
@export var dialogue_after_intro: DialogueResource
@export var dialogue_intro_final: DialogueResource

@export var instruction_manual: Control
var is_manual_visible: bool = false

func _ready() -> void:
	Speaker.player.volume_db = -80.0
	await get_tree().create_timer(1).timeout
	
	#? Play the introduction dialogue
	DialogueManager.show_dialogue_balloon(dialogue_intro)
	await DialogueManager.dialogue_ended
	var tween: Tween = get_tree().create_tween()
	await tween.tween_property(background_overlay, "modulate:a", 0.0, 2.0).finished
	background_overlay.visible = false

	#? Nekogotchi device appearing on screen animation, then let the player press on buttons
	$DeviceAppear.play()
	tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUINT)
	tween.tween_property(nekogotchi, "rotation:y", 0.0, 2.0)
	await tween.parallel().tween_property(nekogotchi, "position:y", 0.0, 2.0).finished
	nekogotchi.can_press = true
	Speaker.player.volume_db = 0.0

	#? Connect the function that runs when the battery holder has been removed
	nekogotchi.battery_holder_removed.connect(play_intro)
	await get_tree().create_timer(20).timeout
	tween = get_tree().create_tween()
	tween.tween_property($HUD/Test, "position:y", -100.0, 10)
	tween.tween_property($HUD/Test, "position:y", 2200.0, 15).set_delay(10)

	
func play_intro() -> void:
	#? Play the intro animation, connect the function that runs when the anim is finished
	nekogotchi.battery_holder_removed.disconnect(play_intro)
	Speaker.intro_song()
	intro_animation.play("intro")
	intro_animation.animation_finished.connect(start_game)


func start_game(_anim_name: String) -> void:
	#? Starts the dialogues, can't press the device while dialogues are running
	nekogotchi.can_press = false
	DialogueManager.show_dialogue_balloon(dialogue_after_intro)
	intro_animation.animation_finished.disconnect(start_game)
	await get_tree().create_timer(1).timeout
	game_screen.visible = true
	await DialogueManager.dialogue_ended
	var tween : Tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUINT)
	tween.tween_property(instruction_manual, "position:y", 50.0, 1.0)
	tween.parallel().tween_property(instruction_manual, "rotation_degrees", 0.0, 1.0)
	$Paper.play()
	instruction_manual.gui_input.connect(after_instructions)

func after_instructions(event: InputEvent) -> void:
	if event.is_pressed() and event is InputEventMouseButton:
		instruction_manual.gui_input.disconnect(after_instructions)
		var tween : Tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUINT)
		tween.tween_property(instruction_manual, "position", Vector2(1161.0, 835.0), 1.0)
		tween.parallel().tween_property(instruction_manual, "rotation_degrees", 3.5, 1.0)
		$Paper.play()
		DialogueManager.show_dialogue_balloon(dialogue_intro_final)
		await DialogueManager.dialogue_ended
		nekogotchi.can_press = true
		instruction_manual.gui_input.connect(toggle_instruction_manual)

func toggle_instruction_manual(event: InputEvent) -> void:
	if event.is_pressed() and event is InputEventMouseButton:
		$Paper.play()
		is_manual_visible = !is_manual_visible
		var tween : Tween = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
		tween.tween_property(instruction_manual, "position", Vector2(200.0, 50.0) if is_manual_visible else Vector2(1161.0, 835.0), 1.0)
		tween.parallel().tween_property(instruction_manual, "rotation_degrees", 0.0 if is_manual_visible else 3.5, 1.0)


func _process(_delta: float) -> void:
	#? Debug keys to skip the intro animation
	if OS.is_debug_build() and Input.is_action_just_pressed("ui_focus_next") and intro_animation.is_playing():
		intro_animation.stop()
		Speaker.player.stop()
		start_game("")
