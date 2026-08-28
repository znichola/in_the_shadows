extends SpotLight3D

@export var flicker_strength: float = 0.4
@export var flicker_time: float = 1.5
@export var sway_strength_deg: float = 1.8
@export var sway_time: float = 3.0

var _base_energy: float
var _rest_rotation: Vector3

func _ready() -> void:
	_base_energy = light_energy
	_rest_rotation = rotation
	_flicker()
	_sway()

func _flicker() -> void:
	var target = _base_energy * (1.0 + randf_range(-flicker_strength, flicker_strength))
	var tween := create_tween()
	tween.tween_property(self, "light_energy", target, flicker_time)
	tween.tween_callback(_flicker)

func _sway() -> void:
	var offset = Vector3(
		randf_range(-sway_strength_deg, sway_strength_deg),
		randf_range(-sway_strength_deg, sway_strength_deg),
		randf_range(-sway_strength_deg, sway_strength_deg)
	)
	var target = _rest_rotation + Vector3(deg_to_rad(offset.x), deg_to_rad(offset.y), deg_to_rad(offset.z))

	var tween := create_tween()
	tween.tween_property(self, "rotation", target, sway_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(_sway)
