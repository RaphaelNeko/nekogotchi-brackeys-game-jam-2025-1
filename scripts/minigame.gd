extends Control

signal on_game_end
signal on_ball_hit

@export var balls_template: Array[Control]
@export var instruction_label: Label
@export var neko: Control

var spawned_balls: Array[Control]
var spawn_speed: float
var ball_speed: float
var lose_game: bool = false
var neko_position: int = 1
var buttons_connected: bool = false

func start_game() -> void:
	spawn_speed = 2.5
	ball_speed = 0.1
	neko.visible = false
	instruction_label.visible = true
	Speaker.sfx_game_start()
	await get_tree().create_timer(3).timeout
	neko.visible = true
	instruction_label.visible = false
	lose_game = false
	get_parent().nekogotchi_device.button_a_pressed.connect(move_neko.bind(-1))
	get_parent().nekogotchi_device.button_b_pressed.connect(move_neko.bind(1))
	get_parent().nekogotchi_device.button_c_pressed.connect(get_parent().minigame_visibility.bind(false))
	buttons_connected = true
	game_playing()

func game_playing() -> void:
	#? Stop the loop if game lost
	if lose_game:
		return
	
	#? Spawn a random ball
	var random_ball: int = randi_range(0, 2)
	var new_ball = balls_template[random_ball].duplicate()
	add_child(new_ball)
	spawned_balls.append(new_ball)
	new_ball.speed = ball_speed
	new_ball.id = random_ball
	new_ball.move()

	await get_tree().create_timer(spawn_speed).timeout
	#? Speed up the game as we play
	spawn_speed -= 0.1
	spawn_speed = clampf(spawn_speed, 0.3, 10)
	ball_speed -= 0.005
	ball_speed = clampf(ball_speed, 0.01, 10)
	game_playing()


func move_neko(dir: int) -> void:
	#? Only allow movements if we haven't lost the game
	if lose_game:
		return
	
	#? Move Neko to the position of the balls
	neko_position += dir
	if neko_position > 2:
		neko_position = 0
	elif neko_position < 0:
		neko_position = 2
	neko.global_position.y = balls_template[neko_position].global_position.y - 64.0
	Speaker.sfx_beep()


func game_lose_anim() -> void:
	lose_game = true

	#? Stop all balls from moving
	for ball in spawned_balls:
		ball.game_lose = true
		ball.stop_anim()
	Speaker.sfx_game_lose()
	
	#? Close the game after 3 seconds
	await get_tree().create_timer(3).timeout
	on_game_end.emit()


func close_game() -> void:
	lose_game = true
	#? Disconnect the signals from the physical buttons
	if buttons_connected:
		get_parent().nekogotchi_device.button_a_pressed.disconnect(move_neko.bind(-1))
		get_parent().nekogotchi_device.button_b_pressed.disconnect(move_neko.bind(1))
		buttons_connected = false

	#? Delete all spawned balls
	if spawned_balls.size() > 0:
		for ball in spawned_balls:
			ball.queue_free()
		spawned_balls.clear()


func _process(_delta: float) -> void:
	if spawned_balls.size() == 0:
		return
	if lose_game:
		return

	#? Checking for each balls position and if it should be hit by Neko, or missed to lose the game
	for ball in spawned_balls:
		if ball.position.x <= 176.0:
			if neko_position == ball.id:
				ball.hit()
				spawned_balls.erase(ball)
				on_ball_hit.emit()
		if ball.position.x <= -4.0:
			game_lose_anim()