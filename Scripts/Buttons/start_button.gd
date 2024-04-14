@tool
extends Button

@export_file var next_scene: String

func _on_button_up():
	get_tree().paused = false
	get_tree().change_scene_to_file(next_scene)
	
func _get_configuration_warnings(): 
	return "next scene must be set for the button" if next_scene == null else ""
