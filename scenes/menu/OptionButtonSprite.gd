extends Sprite2D

@onready var button = %OptionsButton
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	button.connect("button_down", set_second_sprite)
	button.connect("button_up", set_first_sprite)

func set_second_sprite() -> void:
	set_frame(1)
	
func set_first_sprite() -> void:
	set_frame(0)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
