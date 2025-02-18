extends Control

@export var stats: TamaStats

@export_category("Device Reference")
@export var nekogotchi_device: Node3D

@export var neko_anim: AnimationPlayer

@export_category("CHOOSE YOUR NEKO SCREEN")
@export var screen_choose_neko: Control

var choose_neko_selected: int = 0


@export_category("MAIN SCREEN")
@export var screen_main: Control
@export var screen_menu_icons: Control
@export var main_menu_icons: Array[TextureRect]
var selected_main_menu_icon: int = -1

@export var main_menu_time_label: Label
@export var neko_speech_label: Label


@export_category("Sleep References")
var is_lights_off: bool = false
var wanna_sleep: bool = false
@export var sleep_background: Control
@export var no_sleep_overlay: Control


@export_category("STATS VIEWER")
@export var screen_stats_viewer: Control
@export var stats_bar_sprites: Array[CompressedTexture2D]


var time_hour: int = 1
var time_minute: int = 27
var time_is_pm: bool = true


var game_state: GameStateType = GameStateType.INTRO
enum GameStateType {
	INTRO,
	CHOOSE_YOUR_NEKO,
	DAY,
	NIGHT
}

func _ready() -> void:
	screen_main.visible = false
	screen_menu_icons.visible = false
	screen_stats_viewer.visible = false
	screen_choose_neko.visible = true

func game_start() -> void:
	#? Starts the game with the "Choose Your Neko" screen and connects the physical buttons
	game_state = GameStateType.CHOOSE_YOUR_NEKO
	nekogotchi_device.button_a_pressed.connect(choose_neko_move)
	nekogotchi_device.button_b_pressed.connect(choose_neko_confirm)

func _on_visibility_changed() -> void:
	#? After the intro has finished, the game automatically starts with the visibility changed signal
	if !visible:
		return
	if game_state == GameStateType.INTRO:
		game_start()


func choose_neko_move() -> void:
	#? Pressing the A button to switch between the 3 eggs
	choose_neko_selected += 1
	if choose_neko_selected == 3:
		choose_neko_selected = 0
	screen_choose_neko.get_node("Arrow").global_position.x = screen_choose_neko.get_node("EggsContainer").get_child(choose_neko_selected).global_position.x
	Speaker.sfx_beep()

func choose_neko_confirm() -> void:
	#? Select an egg with the B button
	#? Disconnect the physical buttons
	nekogotchi_device.button_a_pressed.disconnect(choose_neko_move)
	nekogotchi_device.button_b_pressed.disconnect(choose_neko_confirm)
	Speaker.sfx_confirm()

	#? Egg selected animation
	var eggs: Array[Node] = screen_choose_neko.get_node("EggsContainer").get_children()
	for i in eggs.size():
		eggs[i].visible = i == choose_neko_selected
	screen_choose_neko.get_node("Arrow").visible = false
	if choose_neko_selected != 1:
		var tween: Tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
		await tween.tween_property(eggs[choose_neko_selected], "position:x", eggs[1].position.x, 1.0).finished
	await get_tree().create_timer(1).timeout
	screen_choose_neko.visible = false
	await get_tree().create_timer(1).timeout

	#? Get to the main screen, connect the main game buttons to the physical buttons
	refresh_time()
	screen_main.visible = true
	screen_menu_icons.visible = true
	Speaker.sfx_beep()
	connect_buttons_to_main_icons()

func main_select_next_icon() -> void:
	#? Selecting the menu icon from the main screen with the A button
	if selected_main_menu_icon != -1:
		main_menu_icons[selected_main_menu_icon].modulate.a = 0.4
	selected_main_menu_icon += 1
	if selected_main_menu_icon >= main_menu_icons.size():
		selected_main_menu_icon = 0
	main_menu_icons[selected_main_menu_icon].modulate.a = 1.0
	Speaker.sfx_beep()

func main_unselect_icon() -> void:
	#? Unselecting the menu icon from the main screen with the C button
	if selected_main_menu_icon != -1:
		main_menu_icons[selected_main_menu_icon].modulate.a = 0.4
	selected_main_menu_icon = -1
	Speaker.sfx_beep()

func main_press_icon() -> void:
	#? Pressing the menu icon from the main screen with the B button
	if selected_main_menu_icon == -1:
		return
	Speaker.sfx_confirm()
	#? Call the correct function depending on the pressed menu icon
	match selected_main_menu_icon:
		1:
			toggle_lights()
		3:
			stats_viewer_visibility(true)


func connect_buttons_to_main_icons() -> void:
	#? Connecting the main screen icons to the physical buttons
	nekogotchi_device.button_a_pressed.connect(main_select_next_icon)
	nekogotchi_device.button_b_pressed.connect(main_press_icon)
	nekogotchi_device.button_c_pressed.connect(main_unselect_icon)

func disconnect_buttons_to_main_icons() -> void:
	#? Disconnecting the main screen icons to the physical buttons
	nekogotchi_device.button_a_pressed.disconnect(main_select_next_icon)
	nekogotchi_device.button_b_pressed.disconnect(main_press_icon)
	nekogotchi_device.button_c_pressed.disconnect(main_unselect_icon)


func toggle_lights() -> void:
	#? Toggling the lights from the main screen
	set_neko_speech()
	is_lights_off = !is_lights_off
	#? Checking if Neko is tired or not. Display the correct screen and animations depending on the tired state.
	wanna_sleep = stats.energy < 0.15
	sleep_background.visible = is_lights_off
	no_sleep_overlay.visible = !wanna_sleep
	neko_anim.play(("sleep" if wanna_sleep else "sleep_not_tired") if is_lights_off else "idle")
	if is_lights_off and !wanna_sleep:
		Speaker.sfx_game_lose()
		set_neko_speech("Don't wanna sleep!!")

func stats_viewer_visibility(visibility: bool) -> void:
	#? Show/Hide the stats viewer screen
	screen_stats_viewer.visible = visibility
	screen_main.visible = !visibility
	#? Connect/Disconnect the stats viewer screen buttons from the physical buttons
	if visibility:
		disconnect_buttons_to_main_icons()
		Speaker.sfx_confirm()
		stats_bars_refresh()
		nekogotchi_device.button_a_pressed.connect(stats_viewer_next)
		nekogotchi_device.button_b_pressed.connect(stats_viewer_next)
		nekogotchi_device.button_c_pressed.connect(stats_viewer_visibility.bind(false))
	else:
		Speaker.sfx_beep()
		nekogotchi_device.button_a_pressed.disconnect(stats_viewer_next)
		nekogotchi_device.button_b_pressed.disconnect(stats_viewer_next)
		nekogotchi_device.button_c_pressed.disconnect(stats_viewer_visibility.bind(false))
		connect_buttons_to_main_icons()

func stats_viewer_next() -> void:
	#? Switch between the stats pages
	Speaker.sfx_confirm()
	screen_stats_viewer.get_child(1).visible = !screen_stats_viewer.get_child(1).visible
	screen_stats_viewer.get_child(0).visible = !screen_stats_viewer.get_child(1).visible

func stats_bars_refresh() -> void:
	#? Refresh all the stats bar textures according to the current stats
	$StatsViewer/Screen1/Energy/Stat.texture = stats_bar_sprites[int(stats.energy * (stats_bar_sprites.size() - 1))]
	$StatsViewer/Screen1/Hunger/Stat.texture = stats_bar_sprites[int(stats.hunger * (stats_bar_sprites.size() - 1))]
	$StatsViewer/Screen2/Fun/Stat.texture = stats_bar_sprites[int(stats.fun * (stats_bar_sprites.size() - 1))]
	$StatsViewer/Screen2/Age/Value.text = str(stats.age)


func set_neko_speech(speech: String = ""):
	#? Show/Hide the speech hud depending if the speech is empty or not
	neko_speech_label.visible = speech != ""
	neko_speech_label.text = speech


func refresh_time() -> void:
	#? Increase the time
	time_minute += 1
	if time_minute >= 60:
		time_minute = 0
		time_hour += 1
		if time_hour > 12:
			time_hour = 1
			if !time_is_pm:
				stats.age += 1
			time_is_pm = !time_is_pm
	main_menu_time_label.text = str(time_hour, ":", "0" if time_minute <= 9 else "", time_minute, " PM" if time_is_pm else " AM")

	#? Decrease the stats
	stats_bars_refresh()
	stats.energy += -0.01 if !is_lights_off else (0.015 if wanna_sleep else -0.01)
	stats.energy = clampf(stats.energy, 0.0, 1.0)
	stats.hunger += -0.025 if !is_lights_off else (-0.05 if wanna_sleep else -0.03)
	stats.hunger = clampf(stats.hunger, 0.0, 1.0)
	stats.fun += -0.02 if !is_lights_off else (-0.05 if wanna_sleep else -0.04)
	stats.fun = clampf(stats.fun, 0.0, 1.0)
	check_for_speech()

	#? Repeat the function every second
	await get_tree().create_timer(1).timeout
	refresh_time()

func check_for_speech():
	#? Do not speech if the main screen isn't visible or the lights are turned off
	if !screen_main.visible:
		return
	if is_lights_off:
		return
	
	#? Force the sleepy speech if it is bed time
	if time_is_pm and time_hour >= 9:
		if neko_speech_label.text != "I am sleepy!!":
			set_neko_speech("I am sleepy!!")
			Speaker.sfx_alert()
			return
	if !time_is_pm and time_hour <= 7:
		if neko_speech_label.text != "I am sleepy!!":
			set_neko_speech("I am sleepy!!")
			Speaker.sfx_alert()
			return
	
	#? Checks for stats to display the correct speech
	if neko_speech_label.text != "Don't wanna sleep!!":
		if stats.fun < 0.15 and neko_speech_label.text != "Let's play!!":
			if neko_speech_label.text != "I am hungry!!":
				if neko_speech_label.text != "I am sleepy!!":
					set_neko_speech("Let's play!!")
					Speaker.sfx_alert()
		if stats.hunger < 0.15 and neko_speech_label.text != "I am hungry!!":
			if neko_speech_label.text != "I am sleepy!!":
				set_neko_speech("I am hungry!!")
				Speaker.sfx_alert()
		if stats.energy < 0.15 and neko_speech_label.text != "I am sleepy!!":
			set_neko_speech("I am sleepy!!")
			Speaker.sfx_alert()

func _process(_delta: float) -> void:
	#? Debug keys for testing
	if OS.is_debug_build() and Input.is_action_just_pressed("ui_focus_next") and game_state != GameStateType.INTRO:
		time_minute += 10
