extends Node3D
class_name ObjectSpawner

signal object_changed(object: ObjectDef)

@export var object_scenes: Array[PackedScene] = []
var current_object_index: int = 0
var current_object: ObjectDef = null


func _ready() -> void:
	for child in get_children():
		child.queue_free()
	_spawn_object(current_object_index)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("object-next"):
		_spawn_object(current_object_index + 1)
	elif event.is_action_pressed("object-prev"):
		_spawn_object(current_object_index - 1)


func _spawn_object(index: int) -> void:
	if current_object:
		current_object.queue_free()
		current_object = null
	if object_scenes.is_empty():
		return
	current_object_index = wrapi(index, 0, object_scenes.size())
	var scene := object_scenes[current_object_index]
	current_object = scene.instantiate() as ObjectDef
	assert(current_object != null, "scene roost must extend ObjectDef: %s" % scene.resource_path)
	add_child(current_object)
	current_object.on_spawn()
	object_changed.emit(current_object)


func reset_current_object() -> void:
	if current_object:
		current_object.on_reset()


func transform_current_object_a(t: Transform3D) -> void:
	if current_object:
		current_object.on_transform_a(t)


func transform_current_object_b(t: Transform3D) -> void:
	if current_object:
		current_object.on_transform_b(t)
	

func is_aligned(alignment_basis: Basis) -> bool:
	if current_object:
		return current_object.is_aligned(alignment_basis)
	return false
