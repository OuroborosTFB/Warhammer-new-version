extends Control

@onready var scene_tree: = get_tree()
@onready var pause_overlay: ColorRect = $PauseOverlay
@onready var menu_overlay: ColorRect = $MenuOverlay
@onready var back_button: Button = $MenuOverlay/BackButton

var is_paused = false : set = set_is_paused
var is_menu_active = false : set = set_active_menu

func _unhandled_input(event):
	if event.is_action_pressed("Pause") and not is_menu_active:
		self.is_paused = not is_paused
		switch_mouse_mode()
	if event.is_action_pressed("Menu") and not is_paused:
		is_menu_active = not is_menu_active
		switch_mouse_mode()

func set_is_paused(value: bool):
	is_paused = value
	scene_tree.paused = value
	pause_overlay.visible = value
	
func set_active_menu(value: bool):
	is_menu_active = value
	scene_tree.paused = value
	menu_overlay.visible = value

func switch_mouse_mode():
	if is_paused or is_menu_active:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN)

func _on_hide_menu_overlay():
	is_menu_active = false
	switch_mouse_mode()
