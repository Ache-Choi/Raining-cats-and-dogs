extends Spatial

export (Vector3) var fromPos
export (Vector3) var toPos
export (String) var windowPos

onready var animPlayer = $netMesh/netMesh/AnimationPlayer
onready var areaCol = $Area/CollisionShape
onready var removeTimer = $removeTimer
onready var tween1 = $Tween
onready var tween2 = $Tween2
onready var savedFxCont = $netMesh/netMesh/netArmature2/savedFxNet
onready var savedSprite = $netMesh/netMesh/netArmature2/saved
var ddbuug

func _ready():
	savedSprite.hide()
	GSignals.update_ui_count(0,0)
	savedFxCont.hide()
	animPlayer.play("goingForward")
	ddbuug = GSignals.connect('removeNet', self, 'remove_net')
	if toPos.x >= 13:
		toPos.x = 13
	elif toPos.x <= -13:
		toPos.x = -13
	tween_move(tween1, self.translation, toPos, .1)
	removeTimer.wait_time = 2.5
	removeTimer.start()
	add_remove_data('add')

func add_remove_data(addRemove):
	if addRemove == 'add':
		for i in GVariables.netInUsePosArrName.size():
			if windowPos == GVariables.netInUsePosArrName[i]:
				GVariables.netInUsePosArrCount[i] += 1
	else:
		for i in GVariables.netInUsePosArrName.size():
			if windowPos == GVariables.netInUsePosArrName[i]:
				GVariables.netInUsePosArrCount[i] -= 1
				if GVariables.netInUsePosArrCount[i] <= 0:
					GVariables.netInUsePosArrCount[i] = 0
					GSignals.open_close_window(windowPos, 'close', 0)

func set_net_limit():
	if GVariables.netAvail > GVariables.netMaxLimit:
		GVariables.netAvail = GVariables.netMaxLimit

func remove_net(netName):
	if self.name == netName:
		areaCol.disabled = true
		disable_static_col()
		GVariables.netAvail += 1
		set_net_limit()
		GSignals.update_ui_count(0,0)
		animPlayer.play("closeNet")
		removeTimer.stop()
		tween_move(tween2, self.translation, fromPos, .25)

func _on_Area_body_entered(body):
	if body.is_in_group('animalDrop'):
		var num = floor(rand_range(1,5))
		GSignals.inst_sounds('caughtAnim%s'%num)
		
		if body.animalType == 0:
			savedSprite.texture = load('res://scenes/animalMesh/animalImgs/savedDog.png')
		else:
			savedSprite.texture = load('res://scenes/animalMesh/animalImgs/savedCat.png')
		areaCol.disabled = true
		GVariables.netAvail += 1
		if windowPos == 'centerRight' or windowPos == 'centerLeft':
			GVariables.savedCounts3F += 1
		elif windowPos == 'topRight' or windowPos == 'topLeft':
			GVariables.savedCounts4F += 1
		else:
			GVariables.savedCounts2F += 1
		set_net_limit()
		GSignals.update_ui_count(1,0)
		body.queue_free()
		animPlayer.play("caughtBounce")
		disable_static_col()
		removeTimer.stop()
		GSignals.inst_items('savedStarFx', self.global_transform.origin, 'positive',0)
	if body.is_in_group('iceDrop'):
		GSignals.inst_sounds('iceCaught')
		GSignals.inst_sounds('negativeCaught')
		savedSprite.scale = Vector3(.7,.7,1)
		GVariables.iceDrops += 1
		savedSprite.texture = load('res://scenes/animalMesh/animalImgs/iceDrop.png')
		animPlayer.play("caughtIceBounce")
		GVariables.netAvail += 1
		disable_static_col()
		removeTimer.stop()
		areaCol.disabled = true
		GSignals.inst_items('noSavedStarFx', self.global_transform.origin, 'negative',0)
		body.queue_free()

func disable_static_col():
	for i in $StaticBody.get_children():
		i.disabled = true

func tween_move(nod, from, to, tim):
#	var tweenArr = [Tween.TRANS_QUAD, Tween.TRANS_QUART, Tween.TRANS_QUINT]
	nod.interpolate_property(self, 'translation', from, to, tim, Tween.TRANS_QUAD,Tween.EASE_IN)
	nod.start()

func tween_rot(nod, from, to, tim):
#	var tweenArr = [Tween.TRANS_QUAD, Tween.TRANS_QUART, Tween.TRANS_QUINT]
	nod.interpolate_property(self, 'rotation_degrees', from, to, tim, Tween.TRANS_QUAD,Tween.EASE_OUT)
	nod.start()

func _on_removeTimer_timeout():
	disable_static_col()
	areaCol.disabled = true
	GVariables.netAvail += 1
	set_net_limit()
	GSignals.update_ui_count(0,0)
	animPlayer.play("closeNet")
	tween_move(tween2, self.translation, fromPos, .25)

func _on_Tween2_tween_completed(object, key):
	add_remove_data('remove')
	self.queue_free()
	ddbuug = [object, key]

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == 'caughtBounce' or anim_name == 'caughtIceBounce' :
		animPlayer.play("closeNet")
		tween_move(tween2, self.translation, fromPos, .25)
	if anim_name == 'goingForward':
		animPlayer.play("goingBounce")

func _on_Area_area_entered(area):
	if area.is_in_group('thunderStrike'):
		areaCol.disabled = true
		disable_static_col()
		GSignals.inst_items('noSavedStarFx', self.global_transform.origin, 'negative',0)
		GVariables.netAvail += 1
		GVariables.lightningHitNet +=1
		removeTimer.stop()
		animPlayer.play("caughtIceBounce")
#		print('thunder sttriked net')
