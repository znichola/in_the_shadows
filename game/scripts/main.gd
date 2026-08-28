extends Node3D

@onready var spawner = $ObjectSpawner
@onready var light = $SpotLight3D
@onready var wall = $MeshInstance3D
@onready var status_label = $CanvasLayer/Control/Label
@onready var status_light = $StatusLight

@export var rotate_speed: float = 2.0    # radians/sec

@export var facing_axis: Vector3 = Vector3.FORWARD   # spawner's local "normal" axis
@export var max_x_misalignment_deg: float = 4.0        # left/right tolerance
@export var max_y_misalignment_deg: float = 8.0        # up/down tolerance

@export var okColor = Color.DARK_GREEN
@export var badColor = Color.FIREBRICK

var is_facing_aligned: bool = false
var x_misalignment_deg: float = 0.0
var y_misalignment_deg: float = 0.0

var initialRotation: Transform3D
var light_to_wall: Vector3
var alignment_basis: Basis

func _ready() -> void:
	initialRotation = spawner.transform
	light_to_wall = (wall.global_transform.origin - light.global_transform.origin).normalized()
	# A basis whose -Z axis points along light_to_wall; X = "right", Y = "up" relative to it.
	alignment_basis = Basis.looking_at(light_to_wall, Vector3.UP)

func _input(event):
	if event.is_action_pressed("turn-reset"):
		spawner.transform = initialRotation

func _process(delta: float) -> void:
	var rl = Input.get_axis("turn-left", "turn-right") * rotate_speed * delta
	var ud = Input.get_axis("turn-up", "turn-down") * rotate_speed * delta
	var t = Transform3D.IDENTITY.rotated(Vector3.LEFT, ud).rotated(Vector3.DOWN, rl)
	spawner.transform *= t

	_update_alignment()
	_update_label(is_facing_aligned)

func _update_alignment() -> void:
	var obj_facing: Vector3 = (spawner.global_transform.basis * facing_axis).normalized()

	# Express obj_facing in the alignment_basis's local space.
	var local_facing := alignment_basis.inverse() * obj_facing

	# Horizontal (x) deviation: angle between local_facing and forward, in the X-Z plane.
	x_misalignment_deg = rad_to_deg(atan2(local_facing.x, -local_facing.z))
	# Vertical (y) deviation: angle between local_facing and forward, in the Y-Z plane.
	y_misalignment_deg = rad_to_deg(atan2(local_facing.y, -local_facing.z))

	is_facing_aligned = absf(x_misalignment_deg) <= max_x_misalignment_deg \
		and absf(y_misalignment_deg) <= max_y_misalignment_deg
		
func _update_label(_is_facing_aligned: bool) -> void:
	if _is_facing_aligned :
		status_label.text = "ALIGNED"
		status_label.modulate = okColor
		status_light.light_color = okColor

	else:
		status_label.text = "NOT ALIGNED"
		status_label.modulate = badColor
		status_light.light_color = badColor
