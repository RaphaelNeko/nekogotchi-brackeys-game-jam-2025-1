extends Node

@export var intro_animation: AnimationPlayer

var game_state: GameStateType = GameStateType.INTRO
enum GameStateType {
	INTRO,
	CHOOSE_YOUR_NEKO,
	DAY,
	NIGHT
}

func _ready() -> void:
	Speaker.intro_song()
	intro_animation.play("intro")

