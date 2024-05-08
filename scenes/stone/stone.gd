extends RigidBody2D
class_name Stone

#(dsmoliakov): move object to player node and enable is_in_hand, so it follows after player 
var is_in_hand = false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func set_in_hand(state):
	is_in_hand = state
	freeze = state
		


func _physics_process(delta: float) -> void:
	pass
		
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
