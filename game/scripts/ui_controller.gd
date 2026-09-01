extends CanvasLayer

@onready var wall_text: RichTextLabel = $Control/WallText

@onready var sign_post: Label = $Control/Signpost
@onready var status_light: OmniLight3D = $StatusLight
var okColor = Color.DARK_GREEN
var badColor = Color.FIREBRICK
var neutralColor = Color.AQUA


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
		sign_post.text = "NOT ALIGNED"
		sign_post.modulate = badColor
		status_light.light_color = badColor
