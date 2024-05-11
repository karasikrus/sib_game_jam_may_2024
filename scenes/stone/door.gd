extends StaticBody2D
class_name Door

@export var lights : Array[DoorLight] = []

@onready var animation_player = $AnimationPlayer

var lights_lit : int = 0

func _ready():
	for door_light in lights:
		(door_light as DoorLight).lit.connect(light)

func light():
	lights_lit += 1
	if lights_lit >= lights.size():
		open()


func open():
	animation_player.play("open")
