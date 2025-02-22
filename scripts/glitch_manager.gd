extends Node

@export var glitch_first: AudioStream
@export var glitch_confirm: AudioStream
@export var glitch_alert: AudioStream
@export var glitch_game: Array[AudioStream]
@export var glitch_random: Array[AudioStream]
@export var glitch_short: AudioStream
@export var glitch_med: AudioStream
@export var glitch_long: AudioStream

@export var player: AudioStreamPlayer

@export var small_glitch_fx: ColorRect
@export var big_glitch_fx: ColorRect

var waiting_for_glitch: bool = false


enum GlitchType {
	FIRST,
	CONFIRM,
	ALERT,
	GAME_START,
	GAME_END,
	RANDOM,
	SHORT, MED, LONG,
}

func queue_glitch(glitch_type: GlitchType = GlitchType.RANDOM) -> void:
	var chances_of_glitch: float = randf()
	if glitch_type == GlitchType.FIRST:
		chances_of_glitch = 1.0
	if glitch_type == GlitchType.LONG:
		chances_of_glitch = 1.0
	if chances_of_glitch < 0.925:
		return
	if waiting_for_glitch:
		return
	waiting_for_glitch = true
	match glitch_type:
		GlitchType.FIRST:
			var random_start: float = randf_range(60.0, 100.0)
			await get_tree().create_timer(random_start).timeout
			player.stream = glitch_first
		GlitchType.CONFIRM:
			player.stream = glitch_confirm
		GlitchType.ALERT:
			player.stream = glitch_alert
		GlitchType.GAME_START:
			player.stream = glitch_game[0]
		GlitchType.GAME_END:
			player.stream = glitch_game[1]
		GlitchType.RANDOM:
			player.stream = glitch_random.pick_random()
		GlitchType.SHORT:
			player.stream = glitch_short
		GlitchType.MED:
			player.stream = glitch_med
		GlitchType.LONG:
			player.stream = glitch_long
	small_glitch_fx.visible = true
	big_glitch_fx.visible = glitch_type == GlitchType.LONG
	player.play()
	await player.finished
	small_glitch_fx.visible = false
	big_glitch_fx.visible = false
	waiting_for_glitch = false