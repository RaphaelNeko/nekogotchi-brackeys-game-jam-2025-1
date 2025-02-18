extends Node

@export var intro_animation: AnimationPlayer
@export var nekogotchi: Node3D
@export var game_screen: Control

func _ready() -> void:
	Speaker.player.volume_db = -80.0
	await get_tree().create_timer(1).timeout

	#? Nekogotchi device appearing on screen animation
	$DeviceAppear.play()
	var tween: Tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUINT)
	tween.tween_property(nekogotchi, "rotation:y", 0.0, 2.0)
	await tween.parallel().tween_property(nekogotchi, "position:y", 0.0, 2.0).finished
	Speaker.player.volume_db = 0.0

	#? Connect the function that runs when the battery holder has been removed
	nekogotchi.battery_holder_removed.connect(play_intro)
	# await get_tree().create_timer(20).timeout
	# tween = get_tree().create_tween()
	# tween.tween_property($HUD/Test, "position:y", -100.0, 10)
	# tween.tween_property($HUD/Test, "position:y", 2200.0, 15).set_delay(10)

	
func play_intro() -> void:
	#? Play the intro animation, connect the function that runs when the anim is finished
	nekogotchi.battery_holder_removed.disconnect(play_intro)
	Speaker.intro_song()
	intro_animation.play("intro")
	intro_animation.animation_finished.connect(start_game)


func start_game(_anim_name: String) -> void:
	#? Starts the game after a second
	intro_animation.animation_finished.disconnect(start_game)
	await get_tree().create_timer(1).timeout
	game_screen.visible = true

func _process(_delta: float) -> void:
	#? Debug keys to skip the intro animation
	if OS.is_debug_build() and Input.is_action_just_pressed("ui_focus_next") and intro_animation.is_playing():
		intro_animation.stop()
		Speaker.player.stop()
		start_game("")
