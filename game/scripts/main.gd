extends Node3D

@onready var spawner = $ObjectSpawner
@onready var wall = $MeshInstance3D
@onready var light = $SpotLight3D
@onready var ui = $UI

@export var rotate_speed: float = 2.0    # radians/sec

var alignment_basis: Basis


func _ready() -> void:
	var light_to_wall = (wall.global_transform.origin - light.global_transform.origin).normalized()
	# A basis whose -Z axis points along light_to_wall; X = "right", Y = "up" relative to it.
	alignment_basis = Basis.looking_at(light_to_wall, Vector3.UP)
	ui.update_label(spawner.is_aligned(alignment_basis))
	spawner.connect('object_changed', _on_object_changed)


func _input(event):
	if event.is_action_pressed("turn-reset"):
		spawner.reset_current_object()
		ui.update_label(spawner.is_aligned(alignment_basis))


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
	ui.update_label(spawner.is_aligned(alignment_basis))

func _on_object_changed(_obj: ObjectDef) -> void:
	ui.update_label(spawner.is_aligned(alignment_basis))
