extends Button

signal hide_menu_overlay

@export var overlay: ColorRect

func _on_button_up():
	overlay.visible = false
	emit_signal("hide_menu_overlay")
