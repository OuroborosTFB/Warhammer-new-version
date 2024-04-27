@tool
extends Button

@onready var head: BoneAttachment3D = $/root/LevelTemplate/Character/Hades_Armature/Skeleton3D/Helm_Head
@onready var mask: BoneAttachment3D =$/root/LevelTemplate/Character/Hades_Armature/Skeleton3D/Helm_Mask
@onready var respirator: BoneAttachment3D = $/root/LevelTemplate/Character/Hades_Armature/Skeleton3D/Helm_Respirator
@onready var visors: BoneAttachment3D = $/root/LevelTemplate/Character/Hades_Armature/Skeleton3D/Helm_Visors

var is_helm_visible = true: set = set_helm_visible

func set_helm_visible(value: bool):
	head.visible = not value
	mask.visible = not value
	respirator.visible = not value
	visors.visible = not value


func _on_toggled(toggled_on):
	is_helm_visible = toggled_on
