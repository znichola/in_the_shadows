extends Node3D
class_name ObjectDef

@export var display_name: String
@export var hint: String

@export var max_x_misalignment_deg: float = 4.0 # left/right tolerance
@export var max_y_misalignment_deg: float = 8.0 # up/down tolerance

@export_group("Object A")
@export var a_x_rot_allowed: bool = true
@export var a_y_rot_allowed: bool = true
@export var a_puzzel_rot_x: float = 0 # left/right tolerance
@export var a_puzzel_rot_y: float = 49.0 # up/down tolerance

@export_group("Object B")
@export var b_x_rot_allowed: bool = true
@export var b_y_rot_allowed: bool = true
@export var b_puzzel_rot_x: float = 0 # left/right tolerance
@export var b_puzzel_rot_y: float = 0 # up/down tolerance

const facing_axis: Vector3 = Vector3.FORWARD

var a: Node3D
var b: Node3D
var aInit: Transform3D
var bInit: Transform3D


func _ready() -> void:
	a = get_node_or_null("ObjA") as Node3D
	b = get_node_or_null("ObjB") as Node3D
	if a:
		aInit = a.transform
		a.rotate_x(deg_to_rad(a_puzzel_rot_x))
		a.rotate_y(deg_to_rad(a_puzzel_rot_y))
	if b:
		bInit = b.transform
		b.rotate_x(deg_to_rad(b_puzzel_rot_x))
		b.rotate_y(deg_to_rad(b_puzzel_rot_y))


func on_spawn() -> void:
	pass


func on_reset() -> void:
	if a:
		a.transform = aInit
	if b:
		b.transform = bInit


func on_transform_a(_t: Transform3D) -> void:
	if not a:
		return
	a.transform *= _filter_rotation(_t, a_x_rot_allowed, a_y_rot_allowed)


func on_transform_b(_t: Transform3D) -> void:
	if not b:
		return
	b.transform *= _filter_rotation(_t, b_x_rot_allowed, b_y_rot_allowed)


# Zeroes out the x and/or y rotation component
func _filter_rotation(_t: Transform3D, x_allowed: bool, y_allowed: bool) -> Transform3D:
	var euler := _t.basis.get_euler()
	euler.x *= float(x_allowed)
	euler.y *= float(y_allowed)
	return Transform3D(Basis.from_euler(euler), _t.origin)


func is_aligned(alignment_basis: Basis) -> bool:
	return _is_node_aligned(a, alignment_basis) and _is_node_aligned(b, alignment_basis)


func _is_node_aligned(node: Node3D, alignment_basis: Basis) -> bool:
	if not node:
		return true
	var node_facing: Vector3 = (node.global_transform.basis * facing_axis).normalized()
	var local_facing := alignment_basis.inverse() * node_facing
	var x_misalignment_deg := rad_to_deg(atan2(local_facing.x, -local_facing.z))
	var y_misalignment_deg := rad_to_deg(atan2(local_facing.y, -local_facing.z))
	return absf(x_misalignment_deg) <= max_x_misalignment_deg and absf(y_misalignment_deg) <= max_y_misalignment_deg
