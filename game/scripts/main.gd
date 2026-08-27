extends Node3D

@onready var obj = $TeaPot
@onready var light = $SpotLight3D
@onready var wall = $MeshInstance3D

@export var rotate_speed: float = 2.0    # radians/sec
var initialRotation: Transform3D

func _ready() -> void:
	initialRotation = obj.transform

func _input(event):
	if event.is_action_pressed("turn-reset"):
		obj.transform = initialRotation

func _process(delta: float) -> void:
	var rl = Input.get_axis("turn-left", "turn-right") * rotate_speed * delta
	var ud = Input.get_axis("turn-up", "turn-down") * rotate_speed * delta
	var t = Transform3D.IDENTITY.rotated(Vector3.UP, ud).rotated(Vector3.LEFT, rl)
	obj.transform *= t
	print("transofrm basis", obj.transform.basis)
	
