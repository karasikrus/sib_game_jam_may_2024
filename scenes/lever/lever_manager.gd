extends Node

signal lever_pressed(id: int)

func press_lever(id: int):
	lever_pressed.emit(id)
