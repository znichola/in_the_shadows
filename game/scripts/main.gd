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
signal level_done

func _ready() -> void:
	var light_to_wall = (wall.global_transform.origin - light.global_transform.origin).normalized()
	# A basis whose -Z axis points along light_to_wall; X = "right", Y = "up" relative to it.
	alignment_basis = Basis.looking_at(light_to_wall, Vector3.UP)
	spawner.connect('object_changed', _on_object_changed)
	level_done.connect(_on_level_done)
	if is_game():
		spawner.spawn_object()

	level_4_start()


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
	var is_aligned = spawner.is_aligned(alignment_basis)
	ui.update_label(is_aligned)
	if is_aligned:
		level_done.emit()


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


func _on_level_done() -> void:
	var level_loaders: Array[Callable] = [
		level_0_start,
		level_1_start,
		level_2_start,
		level_3_start,
		level_4_start,
		level_5_start,
		level_end_start,
	]
	
	var current_level_finished = spawner.current_object_index
	var next_level = clampi(current_level_finished + 1, 0, level_loaders.size())
	game_state = State.CUTSCENE
	ui.set_hint_text("Press space to skip forward")
	if current_level_finished + 1 == level_loaders.size():
		ui.set_sign_post("My journey is complete", Color.BLUE)
	else:
		ui.set_sign_post("The shape is resolved", Color.BLUE)
	await wait_or_skip(8.0)
	spawner.clear_current_object()
	level_loaders[next_level].call()


# Level functions -------------

func level_0_start() -> void:
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


func level_1_start() -> void:
	game_state = State.CUTSCENE
	ui.set_hint_text("Press space to skip forward")
	ui.set_sign_post()
	ui.set_wall_text("A life of shadows and darkness, the third dimension is a distraction, I must focus on the projection ...")
	await wait_or_skip(7.0)
	ui.set_wall_text(".. resolved on to a plane, shadows on a wall, the intent becomes clear.")
	await wait_or_skip(5.0)
	ui.set_wall_text("and yet I feel thirst, a yearning for something hot, a break from this cycle")
	await wait_or_skip(3.0)
	ui.set_sign_post("three thousand years of tradition")
	await wait_or_skip(6.0)
	game_state = State.GAME
	ui.set_hint_text("Use the arrow keys or\nclick & drag to rotate the object")
	ui.set_wall_text()
	spawner.spawn_object(1)


func level_2_start() -> void:
	game_state = State.CUTSCENE
	ui.set_hint_text("Press space to skip forward")
	ui.set_sign_post()
	ui.set_wall_text("I have drunk, and I am not satiated, the taste of sand between my teeth ..")
	await wait_or_skip(4.0)
	ui.set_wall_text("There is no time,\n something else is in the shadows,\na hunters eyes salk me.")
	await wait_or_skip(3.0)
	ui.set_sign_post("Worshipped as gods")
	await wait_or_skip(6.0)
	game_state = State.GAME
	ui.set_hint_text("Use the arrow keys or\nclick & drag to rotate the object")
	ui.set_wall_text()
	spawner.spawn_object(2)


func level_3_start() -> void:
	game_state = State.CUTSCENE
	ui.set_hint_text("Press space to skip forward")
	ui.set_sign_post()
	ui.set_wall_text("This space is small,\nI feel the wall closing in on me,\nno room to breathe")
	await wait_or_skip(7.0)
	ui.set_wall_text("My horizons were once so vast,\nspanning continents and many seas,\nand yet I must put the two pieces together")
	await wait_or_skip(4.0)
	ui.set_sign_post("pale blue dot")
	await wait_or_skip(6.0)
	game_state = State.GAME
	ui.set_hint_text("Use the arrow keys or\nclick & drag to rotate the object")
	ui.set_wall_text()
	spawner.spawn_object(3)


func level_4_start() -> void:
	game_state = State.CUTSCENE
	ui.set_hint_text("Press space to skip forward")
	ui.set_sign_post()
	ui.set_wall_text("Multidimentional objects are the bane of my existence,\nI must look forward,\nkeep moving ...")
	await wait_or_skip(7.0)
	ui.set_wall_text("I will run fast and lord over the forest, I want to renew my bond ..")
	await wait_or_skip(4.0)
	ui.set_sign_post("it sheds its crown every year, and grows it back grander")
	await wait_or_skip(6.0)
	game_state = State.GAME
	ui.set_hint_text("Use the arrow keys or\nclick & drag to rotate the object")
	ui.set_wall_text()
	spawner.spawn_object(4)


func level_5_start() -> void:
	game_state = State.CUTSCENE
	ui.set_hint_text("Press space to skip forward")
	ui.set_sign_post()
	ui.set_wall_text("Where is the connection? An elephant, a teapot, a cat, a small held world, a stag that would not stay still ...")
	await wait_or_skip(7.0)
	ui.set_wall_text("What is the question I even asked? Is there light at the end of this tunnel, or just more shapes in the dark?")
	await wait_or_skip(4.0)
	ui.set_sign_post("the ultimate answer to the ultimate question")
	await wait_or_skip(6.0)
	game_state = State.GAME
	ui.set_hint_text("Use the arrow keys or\nclick & drag to rotate the object")
	ui.set_wall_text()
	spawner.spawn_object(5)

func level_end_start() -> void:
	game_state = State.CUTSCENE
	ui.set_hint_text("Press space to skip forward")
	ui.set_sign_post()
	ui.set_wall_text(".. I emerge from the darkness, no longer a world of flat shadows,\nI stand on the sholders of giants,\nand I see far.")
	await wait_or_skip(6.0)
	ui.set_sign_post("My journey is complete", Color.BLUE)
	await wait_or_skip(5.0)
	ui.set_hint_text("Press space to restart")

	
	
