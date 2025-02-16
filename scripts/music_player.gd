extends Node

@onready var player_main: AudioStreamPlayer = $Main
@onready var player_success: AudioStreamPlayer = $Success
@onready var player_defeat: AudioStreamPlayer = $Defeat
@onready var player_end_chime: AudioStreamPlayer = $EndChime

var tween_drums: bool = false
var drums_target_volume: float = -80.0
var drums_smooth_volume: float = -80.0

func play_main(drums: bool = true) -> void:
	if player_success.playing:
		stop_playing(player_success, 3.0)
		await get_tree().create_timer(0.5).timeout
	if player_defeat.playing:
		stop_playing(player_defeat, 3.0)
		await get_tree().create_timer(0.5).timeout
	player_main.volume_db = 0.0
	drums_target_volume = 0.0 if drums else -80.0
	if player_main.playing:
		tween_drums = true
	else:
		player_main.stream.set_sync_stream_volume(1, drums_target_volume)
		player_main.play()

func play_ending(is_success: bool) -> void:
	player_end_chime.play()
	if player_main.playing:
		stop_playing(player_main)
	await get_tree().create_timer(3).timeout
	var player: AudioStreamPlayer = player_success if is_success else player_defeat
	player.volume_db = 0.0
	player.play()
	
func stop_playing(player: AudioStreamPlayer, fade_time: float = 1.0) -> void:
	var tween: Tween = get_tree().create_tween()
	await tween.tween_property(player, "volume_db", -80.0, fade_time).finished
	player.stop()

func _process(delta: float):
	if !tween_drums:
		return
	if player_main.stream.get_sync_stream_volume(1) == drums_target_volume:
		tween_drums = false
		return
	player_main.stream.set_sync_stream_volume(1, drums_smooth_volume)
	drums_smooth_volume = lerpf(drums_smooth_volume, drums_target_volume, 7.0 * delta)