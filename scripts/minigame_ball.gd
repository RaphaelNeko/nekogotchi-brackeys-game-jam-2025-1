extends Control

var speed: float
var hitting: bool = false
var id: int = 0
var game_lose: bool = false

func move() -> void:
	if game_lose:
		return
	if hitting:
		return
	position.x -= 8.0
	await get_tree().create_timer(speed).timeout
	move()

func hit() -> void:
	Speaker.sfx_game_win()
	hitting = true
	$BallAnim.play("hit")
	var tween: Tween = get_tree().create_tween()
	await tween.tween_property(self, "position", position + Vector2(50.0, -20.0), 0.4).finished
	queue_free()

func stop_anim() -> void:
	$BallAnim.stop()
