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

func play_sfx(sfxID: int):
	if player.stream == sfx[0] and player.playing:
		return
	player.stream = sfx[sfxID]
	player.play()