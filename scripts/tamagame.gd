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
@export var sleep_background: Control
@export var no_sleep_overlay: Control


@export_category("STATS VIEWER")
@export var screen_stats_viewer: Control


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
	screen_choose_neko.visible = true

func game_start() -> void:
	game_state = GameStateType.CHOOSE_YOUR_NEKO
	nekogotchi_device.button_a_pressed.connect(choose_neko_move)
	nekogotchi_device.button_b_pressed.connect(choose_neko_confirm)

func _on_visibility_changed() -> void:
	if !visible:
		return
	if game_state == GameStateType.INTRO:
		game_start()


func choose_neko_move() -> void:
	choose_neko_selected += 1
	if choose_neko_selected == 3:
		choose_neko_selected = 0
	screen_choose_neko.get_node("Arrow").global_position.x = screen_choose_neko.get_node("EggsContainer").get_child(choose_neko_selected).global_position.x
	Speaker.sfx_beep()

func choose_neko_confirm() -> void:
	nekogotchi_device.button_a_pressed.disconnect(choose_neko_move)
	nekogotchi_device.button_b_pressed.disconnect(choose_neko_confirm)
	Speaker.sfx_confirm()
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
	refresh_time()
	screen_main.visible = true
	screen_menu_icons.visible = true
	Speaker.sfx_alert()
	connect_buttons_to_main_icons()

func main_select_next_icon() -> void:
	if selected_main_menu_icon != -1:
		main_menu_icons[selected_main_menu_icon].modulate.a = 0.4
	selected_main_menu_icon += 1
	if selected_main_menu_icon >= main_menu_icons.size():
		selected_main_menu_icon = 0
	main_menu_icons[selected_main_menu_icon].modulate.a = 1.0
	Speaker.sfx_beep()

func main_unselect_icon() -> void:
	if selected_main_menu_icon != -1:
		main_menu_icons[selected_main_menu_icon].modulate.a = 0.4
	selected_main_menu_icon = -1
	Speaker.sfx_beep()

func main_press_icon() -> void:
	if selected_main_menu_icon == -1:
		return
	Speaker.sfx_confirm()
	match selected_main_menu_icon:
		1:
			toggle_lights()
		3:
			stats_viewer_visibility(true)


func connect_buttons_to_main_icons() -> void:
	nekogotchi_device.button_a_pressed.connect(main_select_next_icon)
	nekogotchi_device.button_b_pressed.connect(main_press_icon)
	nekogotchi_device.button_c_pressed.connect(main_unselect_icon)

func disconnect_buttons_to_main_icons() -> void:
	nekogotchi_device.button_a_pressed.disconnect(main_select_next_icon)
	nekogotchi_device.button_b_pressed.disconnect(main_press_icon)
	nekogotchi_device.button_c_pressed.disconnect(main_unselect_icon)


func toggle_lights() -> void:
	set_neko_speech()
	is_lights_off = !is_lights_off
	sleep_background.visible = is_lights_off
	no_sleep_overlay.visible = stats.energy > 0.15
	neko_anim.play(("sleep_not_tired" if no_sleep_overlay.visible else "sleep") if is_lights_off else "idle")
	if is_lights_off and stats.energy > 0.15:
		Speaker.sfx_game_lose()
		set_neko_speech("Don't wanna sleep!!")

func stats_viewer_visibility(visibility: bool) -> void:
	screen_stats_viewer.visible = visibility
	screen_main.visible = !visibility
	if visibility:
		disconnect_buttons_to_main_icons()
		Speaker.sfx_confirm()
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
	Speaker.sfx_confirm()
	screen_stats_viewer.get_child(1).visible = !screen_stats_viewer.get_child(1).visible
	screen_stats_viewer.get_child(0).visible = !screen_stats_viewer.get_child(1).visible


func set_neko_speech(speech: String = ""):
	neko_speech_label.visible = speech != ""
	neko_speech_label.text = speech


func refresh_time() -> void:
	time_minute += 1
	if time_minute >= 60:
		time_minute = 0
		time_hour += 1
		if time_hour > 12:
			time_hour = 1
			time_is_pm = !time_is_pm
	main_menu_time_label.text = str(time_hour, ":", "0" if time_minute <= 9 else "", time_minute, " PM" if time_is_pm else " AM")
	await get_tree().create_timer(1).timeout
	refresh_time()

func _process(_delta: float) -> void:
	if OS.is_debug_build() and Input.is_action_just_pressed("ui_focus_next") and game_state != GameStateType.INTRO:
		time_minute += 10
