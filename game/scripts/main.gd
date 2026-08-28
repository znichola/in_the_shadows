extends Node3D

@onready var spawner = $ObjectSpawner
@onready var light = $SpotLight3D
@onready var wall = $MeshInstance3D
@onready var status_label = $CanvasLayer/Control/Label
@onready var status_light = $StatusLight

@export var okColor = Color.DARK_GREEN
@export var badColor = Color.FIREBRICK

@export var rotate_speed: float = 2.0    # radians/sec

var alignment_basis: Basis


func _ready() -> void:
	var light_to_wall = (wall.global_transform.origin - light.global_transform.origin).normalized()
	# A basis whose -Z axis points along light_to_wall; X = "right", Y = "up" relative to it.
	alignment_basis = Basis.looking_at(light_to_wall, Vector3.UP)
	_update_label()
	spawner.connect('object_changed', _on_object_changed)


func _input(event):
	if event.is_action_pressed("turn-reset"):
		spawner.reset_current_object()
		_update_label()


func _process(delta: float) -> void:
	var rl = Input.get_axis("turn-left", "turn-right") * rotate_speed * delta
	var ud = Input.get_axis("turn-up", "turn-down") * rotate_speed * delta
	if rl == 0 and ud == 0:
		return
	var t = Transform3D.IDENTITY.rotated(Vector3.LEFT, ud).rotated(Vector3.DOWN, rl)

	if Input.is_action_pressed("object-alt"):
		spawner.transform_current_object_b(t)
	else:
		spawner.transform_current_object_a(t)
	_update_label()


func _update_label() -> void:
	if spawner.is_aligned(alignment_basis) :
		status_label.text = "ALIGNED"
		status_label.modulate = okColor
		status_light.light_color = okColor

	else:
		status_label.text = "NOT ALIGNED"
		status_label.modulate = badColor
		status_light.light_color = badColor


func _on_object_changed(_obj: ObjectDef) -> void:
	_update_label()
