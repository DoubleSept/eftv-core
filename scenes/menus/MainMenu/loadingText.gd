tool
extends Label

var textStr : String = tr("TEXT_LOADING")
var isPointAsc : bool = true
var nbPoints : int = 0
var secPoints : float = 0.25
var elapsedSinceLast : float = 0.0

const NB_POINTS_MAX = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(true)

func repeat_string(_str:String, count:int) -> String:
	var returnStr : String = ""
	for _i in range(count):
		returnStr += _str
	return returnStr

func _process(delta):
	elapsedSinceLast += delta
	if elapsedSinceLast > secPoints:
		elapsedSinceLast -= secPoints
		if isPointAsc:
			nbPoints += 1
			if nbPoints > NB_POINTS_MAX:
				nbPoints = NB_POINTS_MAX - 1
				isPointAsc = false
		else:
			nbPoints -= 1
			if nbPoints < 0:
				nbPoints = 1
				isPointAsc = true
		self.text = textStr + repeat_string(".", nbPoints)
