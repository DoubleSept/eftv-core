extends RichTextLabel

export var text_key = "TEXT_SECRET_FOUND"

const bbCodeStart = "[wave amp=40 freq=4][center]"
const bbCodeEnd = "[center]" #Yeah we are not closing but centering

func _ready():
	bbcode_text = bbCodeStart+tr(text_key)+bbCodeEnd


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
