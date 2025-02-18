extends Node

@export var sfx: Array[AudioStream]
@export var player: AudioStreamPlayer

func intro_song() -> void:
	player.stream = sfx[0]
	player.play()

func sfx_alert() -> void:
	play_sfx(1)

func sfx_beep() -> void:
	play_sfx(2)

func sfx_confirm() -> void:
	play_sfx(3)

func sfx_game_start() -> void:
	play_sfx(4)

func sfx_game_win() -> void:
	play_sfx(5)

func sfx_game_lose() -> void:
	play_sfx(6)

func sfx_eating() -> void:
	play_sfx(7)

func play_sfx(sfxID: int):
	if player.stream == sfx[0] and player.playing:
		return
	player.stream = sfx[sfxID]
	player.play()