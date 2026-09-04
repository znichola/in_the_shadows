extends Node3D

@onready var spawner = $ObjectSpawner
@onready var wall = $MeshInstance3D
@onready var light = $SpotLight3D
@onready var ui = $UI

@export var rotate_speed: float = 2.0    # radians/sec

var alignment_basis: Basis

enum State { MENU, GAME, CUTSCENE }
var game_state: State = State.MENU

signal skip_requested

func _ready() -> void:
	var light_to_wall = (wall.global_transform.origin - light.global_transform.origin).normalized()
	# A basis whose -Z axis points along light_to_wall; X = "right", Y = "up" relative to it.
	alignment_basis = Basis.looking_at(light_to_wall, Vector3.UP)
	spawner.connect('object_changed', _on_object_changed)
	if is_game():
		spawner.spawn_object()

	level_1_start()


func _input(event):
	if is_menu():
		return

	if is_cutscene():
		if event.is_action_pressed("ui_accept"):
			skip_requested.emit()
		return

	if is_game():
		if event.is_action_pressed("object-next"):
			spawner.next_object()
		if event.is_action_pressed("object-prev"):
			spawner.previous_object()
		if event.is_action_pressed("turn-reset"):
			spawner.reset_current_object()
			ui.update_label(spawner.is_aligned(alignment_basis))


func _process(delta: float) -> void:
	if is_menu() or is_cutscene():
		return

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


func is_menu() -> bool:
	return game_state == State.MENU

func is_game() -> bool:
	return game_state == State.GAME

func is_cutscene() -> bool:
	return game_state == State.CUTSCENE

func wait_or_skip(seconds: float) -> void:
	if is_cutscene():
		get_tree().create_timer(seconds).timeout.connect(func(): skip_requested.emit())
		await skip_requested


# Level functions -------------

func level_1_start() -> void:
	game_state = State.CUTSCENE
	ui.set_hint_text("Press space to skip forward")
	ui.set_sign_post()
	ui.set_wall_text("Where am I?\nWhat is this dark place, I see nothing but faceless rock around me, there must be a way out of here ...")
	await wait_or_skip(8.0)
	ui.set_wall_text("What is this object, if only I could remember ...")
	await wait_or_skip(2.0)
	ui.set_sign_post("known for their long memory")
	await wait_or_skip(6.0)
	game_state = State.GAME
	ui.set_hint_text("Use the arrow keys or\nclick & drag to rotate the object")
	ui.set_wall_text()
	spawner.spawn_object(0)


func level_2_start() -> void:
	game_state = State.CUTSCENE
	ui.set_hint_text("Press space to skip forward")
	ui.set_sign_post()
	ui.set_wall_text("A life of shadows and darkness, the third dimension is a distraction, I must focus on the projection ...")
	await wait_or_skip(7.0)
	ui.set_wall_text(".. resolved on to a plane, shadows on a wall, the intent becomes clear.")
	await wait_or_skip(5.0)
	ui.set_wall_text("and yet I feel thurst, a yearning for something hot, a break from this cycle")
	await wait_or_skip(3.0)
	ui.set_sign_post("a 3000 year of tradition")
	await wait_or_skip(6.0)
	game_state = State.GAME
	ui.set_hint_text("Use the arrow keys or\nclick & drag to rotate the object")
	ui.set_wall_text()
	spawner.spawn_object(1)


# level 3 object is a cat

# level 4 is a globe

# level 5 object is a deer in motion

# level 6 is the number 42
