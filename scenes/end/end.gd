extends TextureRect


func change_to_main_menu():
	SceneTransition.close_screen()
	await SceneTransition.transition_halfway
	get_tree().change_scene_to_file("res://scenes/menu/main_menu.tscn")
	SceneTransition.open_screen()
