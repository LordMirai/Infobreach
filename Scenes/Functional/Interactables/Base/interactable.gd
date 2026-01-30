extends StaticBody2D


@export var interactable_name: String
@export var can_interact: bool = true
@export var single_use: bool = false
@export var interaction_prompt: String = "Press [Space] to interact"



func sub_interact(): # extend by children
	pass
	
	
func _on_interact():
	if can_interact:
		print("Interactable trigger -- " + interactable_name)
		# ...
		
		sub_interact()


		if single_use:
			can_interact = false
	
