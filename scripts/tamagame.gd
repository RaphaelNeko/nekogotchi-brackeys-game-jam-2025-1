extends Control

@export var nekogotchi_device: Node3D

@export var screen_choose_neko: Control
@export var screen_main: Control

var choose_neko_selected: int = 0

@export var main_menu_icons: Array[TextureRect]
var selected_main_menu_icon: int = -1





var game_state: GameStateType = GameStateType.INTRO
enum GameStateType {
	INTRO,
	CHOOSE_YOUR_NEKO,
	DAY,
	NIGHT
}

func _ready() -> void:
	screen_main.visible = false
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
	screen_main.visible = true
	Speaker.sfx_alert()
	nekogotchi_device.button_a_pressed.connect(main_select_next_icon)
	nekogotchi_device.button_b_pressed.connect(main_press_icon)
	nekogotchi_device.button_c_pressed.connect(main_unselect_icon)


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