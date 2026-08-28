extends Node3D
class_name ObjectSpawner

## Emitted whenever the active object changes (including the initial spawn).
signal object_changed(object: Node3D, def: ObjectDef)

@export var object_defs: Array[ObjectDef] = []

var current_object_index: int = 0
var current_object: Node3D = null
var current_rest_transform: Transform3D


func _ready() -> void:
	var children = get_children()
	for child in children:
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

	if object_defs.is_empty():
		return

	current_object_index = wrapi(index, 0, object_defs.size())
	var def := object_defs[current_object_index]

	current_object = def.scene.instantiate()
	add_child(current_object)
	current_rest_transform = current_object.transform

	object_changed.emit(current_object, def)


func reset_current_object() -> void:
	if current_object:
		current_object.transform = current_rest_transform
