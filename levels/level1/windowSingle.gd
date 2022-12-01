extends Spatial

export (String) var windowPosName
export (String) var openClose

onready var tween = $Tween
onready var timer = $Timer
onready var mesh = $mesh
var ddbuug


func _ready():
	openClose = 'close'
	ddbuug = GSignals.connect('openCloseWindow', self, 'open_close_window')
	timer.wait_time = 3

func open_close_window(windowPosString, extra1, extra2):
	if windowPosName == windowPosString:
		if extra1 == 'open':
			tween_move(tween, mesh.rotation_degrees, Vector3(65,0,0), .2)
			GSignals.inst_sounds('winOpen')
		else:
			tween_move(tween, mesh.rotation_degrees, Vector3(0,0,0), .2)
			GSignals.inst_sounds('winClose')
	ddbuug = extra2


func close_window(windowPosString):
	if windowPosName == windowPosString:
		tween_move(tween, mesh.rotation_degrees, Vector3(0,0,0), .3)

func tween_move(nod, from, to, tim):
#	var tweenArr = [Tween.TRANS_QUAD, Tween.TRANS_QUART, Tween.TRANS_QUINT]
	nod.interpolate_property(mesh, 'rotation_degrees', from, to, tim, Tween.TRANS_QUAD,Tween.EASE_OUT)
	nod.start()

func _on_Tween_tween_completed(object, key):
	if openClose == 'open':
		timer.start()
	ddbuug = [object, key]


func _on_Timer_timeout():
	tween_move(tween, mesh.rotation_degrees, Vector3(0,0,0), .5)
	openClose = 'close'
#	print('closed     ----      window single scene')
