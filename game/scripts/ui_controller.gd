extends CanvasLayer

@onready var wall_text: RichTextLabel = $Control/WallText

@onready var sign_post: Label = $Control/Signpost
@onready var status_light: OmniLight3D = $StatusLight
var okColor = Color.DARK_GREEN
var badColor = Color.FIREBRICK
var neutralColor = Color.AQUA

@onready var hint_text: Label = $Control/HintText


func onready():
	status_light.modulate = neutralColor
	sign_post.test = "Neutral position"
	pass


func update_label(is_aligned: bool) -> void:
	if is_aligned:
		sign_post.text = "ALIGNED"
		sign_post.modulate = okColor
		status_light.light_color = okColor

	else:
		pass
		sign_post.text = "NOT ALIGNED"
		sign_post.modulate = badColor
		status_light.light_color = badColor


func set_sign_post(text: String = "", color: Color = Color.WHITE_SMOKE) -> void:
	sign_post.text = text
	sign_post.modulate = color
	status_light.light_color = color
	status_light.light_energy = 0 if text == "" else 14


func set_wall_text(text: String = "") -> void:
	wall_text.text = text
	

func set_hint_text(text: String = "") -> void:
	hint_text.text = text
