extends Node

@export var intro_animation: AnimationPlayer
@export var nekogotchi: Node3D
@export var game_screen: Control

func _ready() -> void:
	Speaker.player.volume_db = -80.0
	var tween: Tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUINT)
	tween.tween_property(nekogotchi, "rotation:y", 0.0, 2.0)
	await tween.parallel().tween_property(nekogotchi, "position:y", 0.0, 2.0).finished
	Speaker.player.volume_db = 0.0
	nekogotchi.button_a_pressed.connect(play_intro)
	nekogotchi.button_b_pressed.connect(play_intro)
	nekogotchi.button_c_pressed.connect(play_intro)

	
func play_intro() -> void:
	nekogotchi.button_a_pressed.disconnect(play_intro)
	nekogotchi.button_b_pressed.disconnect(play_intro)
	nekogotchi.button_c_pressed.disconnect(play_intro)
	Speaker.intro_song()
	intro_animation.play("intro")
	intro_animation.animation_finished.connect(start_game)


func start_game(_anim_name: String) -> void:
	intro_animation.animation_finished.disconnect(start_game)
	await get_tree().create_timer(1).timeout
	game_screen.visible = true

func _process(_delta: float) -> void:
	if OS.is_debug_build() and Input.is_action_just_pressed("ui_focus_next") and intro_animation.is_playing():
		intro_animation.stop()
		Speaker.player.stop()
		start_game("")
