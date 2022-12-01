extends Spatial

signal replace_main_scene # Useless, but needed as there is no clean way to check if a node exposes a signal
export (PackedScene) var catchingNet
export (PackedScene) var animalRain
export (PackedScene) var dropContactFx
export (PackedScene) var groundExplode
export (PackedScene) var iceGroundExplode
export (PackedScene) var savedStarsFx
export (PackedScene) var closeWindow
export (PackedScene) var iceDrop
export (PackedScene) var thunderStrike

onready var cam = $camLight/Camera
onready var ray = $camLight/Camera/RayCast
onready var animalSpawnTimer = $Timer
var cursorContactPos

var ddbuug


func _ready():
	GVariables.savedCounts2F = 0
	GVariables.savedCounts3F = 0
	GVariables.savedCounts4F = 0
	GVariables.iceDrops = 0
	GVariables.lightningHitNet = 0
	GVariables.netInUsePosArrCount = [0,0,0,0,0,0]
	randomize()
	ddbuug = GSignals.connect('changeSceneSignal', self, 'change_scene')
	ddbuug = GSignals.connect('contactFx', self, 'inst_contact_fx')
	ddbuug = GSignals.connect('groundExplodeFx', self, 'inst_ground_fx')
	ddbuug = GSignals.connect('instItems', self, 'inst_items')
	ddbuug = GSignals.connect('stopGame', self, 'game_stop')
	ddbuug = GSignals.connect('closeWindow', self, 'close_window')
	animalSpawnTimer.wait_time = 1
	if GVariables.currentLevel < GVariables.availLevel:
		GSignals.inst_global_msg('level%s'%GVariables.currentLevel)
	else:
		GSignals.inst_global_msg('level%s'%str(GVariables.currentLevel,GVariables.currentLevel))
	yield(get_tree().create_timer(3), 'timeout')
	animalSpawnTimer.start()
	GVariables.gameOn = true

func change_scene():
	GVariables.nextScenePath = 'res://scenes/ui/transitionPage.tscn'
	var path = GVariables.nextScenePath
	emit_signal("replace_main_scene", ResourceLoader.load(path))

func close_window():
	GVariables.gameOn = false
	var w = closeWindow.instance()
	add_child(w)

func game_stop(extra1, extra2):
	GVariables.gameOn = false
	animalSpawnTimer.stop()
	ddbuug = [extra1, extra2]

func _process(delta):
	ddbuug = delta
	var ray_length = 250
	var mouse_pos = get_viewport().get_mouse_position()
	var to = cam.project_local_ray_normal(mouse_pos) * ray_length
	ray.cast_to = to
	ray.force_raycast_update()
	if GVariables.gameOn:
		if ray.is_colliding():
			var collider = ray.get_collider()
			cursorContactPos = ray.get_collision_point() * Vector3(1,1,1)

		if(Input.is_action_just_pressed('mouse_left')):
			if ray.is_colliding():
				if ray.get_collider().name == 'staticCursorCol' and GVariables.netAvail > 0:
					GVariables.netAvail -= 1
					var collider = ray.get_collider()
					cursorContactPos = ray.get_collision_point() * Vector3(1,1,1)
	#				print(cursorContactPos)
					inst_catching_net(cursorContactPos)
				elif ray.get_collider().name == 'removeNetCol':
					GSignals.remove_net_signal(ray.get_collider().get_parent().name)
#				print(ray.get_collider().get_parent().name , '      remove net      ', ray.get_collider().get_parent().uniqNum)
#			print(ray.get_collider().name, '           levelCont scene ')


#	if ray.is_colliding():
#		cursorContactPos = ray.get_collision_point() * Vector3(1,1,1)
#		print(ray.get_collider().name, '      collider.name ')
#       $catchingNet.look_at(cursor,Vector3(0,0,1))

# CatchNet Item
# startPos fromPos
# bottom right z = 14.5 to 17
# bottom right y = 15 to 20

# contact toPos
# topLeft      Vector3(15,25,0)       topCenter      Vector3(0,25,0)
# bottomLeft   Vector3(15,9.3,0)      bottomCenter   Vector3(0,9.3,0)

func open_close_win(winPos):
	for i in GVariables.netInUsePosArrName.size():
		if winPos == GVariables.netInUsePosArrName[i]:
			if GVariables.netInUsePosArrCount[i] <= 0:
				GVariables.netInUsePosArrCount[i] = 0
				GSignals.open_close_window(winPos, 'open', 0)

func inst_catching_net(clickPos):
	if clickPos.x >= 0 and clickPos.y < 25:
#		GSignals.open_close_window('bottomRight', 0, 0)
		open_close_win('bottomRight')
		var n = catchingNet.instance()
		var startPos = Vector3(-16.1, rand_range(17,20), rand_range(14.5, 17))
		n.translation = startPos
		n.toPos = clickPos
		n.fromPos = startPos
		n.windowPos = 'bottomRight'
		add_child(n)
		n.look_at(clickPos,Vector3(0,10,-1))
	if clickPos.x < 0 and clickPos.y < 25:
		open_close_win('bottomLeft')
		var n = catchingNet.instance()
		var startPos = Vector3(16.1, rand_range(17,20), rand_range(14.5, 17))
		n.translation = startPos
		n.toPos = clickPos
		n.fromPos = startPos
		n.windowPos = 'bottomLeft'
		add_child(n)
		n.look_at(clickPos,Vector3(0,10,-1))
	if clickPos.x >= 0 and clickPos.y >= 25 and clickPos.y < 38:
		open_close_win('centerRight')
		var n = catchingNet.instance()
		var startPos = Vector3(-16.1, rand_range(27,32), rand_range(14.5, 17))
		n.translation = startPos
		n.toPos = clickPos
		n.fromPos = startPos
		n.windowPos = 'centerRight'
		add_child(n)
		n.look_at(clickPos,Vector3(0,10,-1))
	if clickPos.x < 0 and clickPos.y >= 25 and clickPos.y < 38:
		open_close_win('centerLeft')
		var n = catchingNet.instance()
		var startPos = Vector3(16.1, rand_range(27,32), rand_range(14.5, 17))
		n.translation = startPos
		n.toPos = clickPos
		n.fromPos = startPos
		n.windowPos = 'centerLeft'
		add_child(n)
		n.look_at(clickPos,Vector3(0,10,-1))
	if clickPos.x >= 0 and clickPos.y >= 38:
		open_close_win('topRight')
		var n = catchingNet.instance()
		var startPos = Vector3(-16.1, rand_range(39,42), rand_range(14.5, 17))
		n.translation = startPos
		n.toPos = clickPos
		n.fromPos = startPos
		n.windowPos = 'topRight'
		add_child(n)
		n.look_at(clickPos,Vector3(0,10,-1))
	if clickPos.x < 0 and clickPos.y >= 38:
		open_close_win('topLeft')
		var n = catchingNet.instance()
		var startPos = Vector3(16.1, rand_range(39,42), rand_range(14.5, 17))
		n.translation = startPos
		n.toPos = clickPos
		n.fromPos = startPos
		n.windowPos = 'topLeft'
		add_child(n)
		n.look_at(clickPos,Vector3(0,10,-1))

func inst_contact_fx(fxType, pos, extra1, extra2): # fxtype == dropContact  ,  sideContact
	var d = dropContactFx.instance()
	if extra1 == 'left':
		d.translation = Vector3(15.6,pos.y,0)
	elif extra1 == 'right':
		d.translation = Vector3(-15.6,pos.y,0)
	else:
		d.translation = Vector3(pos.x,pos.y,0)
	d.fxType = fxType
	add_child(d)
	ddbuug = extra2

func inst_ground_fx(fxType, pos, extra1, extra2):
	if fxType == 'animalGroundExplode':
		var g = groundExplode.instance()
		g.translation = Vector3(pos.x,0.2,0)
		add_child(g)
	elif fxType == 'iceGroundExplode':
		var g = iceGroundExplode.instance()
		g.translation = Vector3(pos.x,0.2,0)
		add_child(g)
	ddbuug = extra1
	ddbuug = extra2

func inst_animal_rain(typeNum):
	if typeNum == 0 or typeNum == 1:
		var a = animalRain.instance()
		a.translation = Vector3(rand_range(-15,15),58,0)
		if GVariables.currentLevel == 0:
			a.linear_velocity = Vector3(0,rand_range(-25,-35),0)
		elif GVariables.currentLevel == 1:
			a.linear_velocity = Vector3(0,rand_range(-25,-35),0)
		elif GVariables.currentLevel == 2:
			a.linear_velocity = Vector3(rand_range(-20,20),rand_range(-25,-35),0)
		elif GVariables.currentLevel >= 3:
			a.linear_velocity = Vector3(rand_range(-20,20),rand_range(-25,-35),0)
			
		a.animalType = typeNum
		add_child(a)
	else:
		var i = iceDrop.instance()
		i.translation = Vector3(rand_range(-15,15),58,0)
		i.linear_velocity = Vector3(rand_range(-20,20),rand_range(-25,-35),0)
		add_child(i)

func inst_items(itemType, pos, extra1, extra2):
	var s = savedStarsFx.instance()
	s.translation = pos
	s.countPosNeg = extra1

#	if itemType == 'savedStarFx':
#		s.countPosNeg = extra1
#	elif itemType == 'enemy':
#		s.countPosNeg = extra1
	add_child(s)
	ddbuug = extra2

var ligtningCountDown = 5

func _on_Timer_timeout():
	if GVariables.currentLevel == 0:
		animalSpawnTimer.wait_time = rand_range(1,2)
		var num = floor(rand_range(0,2))
		inst_animal_rain(num)
	elif GVariables.currentLevel == 1:
		animalSpawnTimer.wait_time = rand_range(.8,1.3)
		var num = floor(rand_range(0,2))
		inst_animal_rain(num)
	elif GVariables.currentLevel == 2:
		animalSpawnTimer.wait_time = rand_range(0.5,1)
		var num = floor(rand_range(0,2))
		inst_animal_rain(num)
	elif GVariables.currentLevel == 3:
		animalSpawnTimer.wait_time = rand_range(.3,.9)
		var num = floor(rand_range(0,3))
		inst_animal_rain(num)
	elif GVariables.currentLevel == 4:
		animalSpawnTimer.wait_time = rand_range(.2,.7)
		var num = floor(rand_range(0,3))
		inst_animal_rain(num)
		ligtningCountDown -= 1
		if ligtningCountDown == 0:
			ligtningCountDown = 5
			var instOrNot = rand_range(0,10)
			if instOrNot < 3.5:
				inst_thunder()

		# add ligting 30%


func inst_thunder():
	var t = thunderStrike.instance()
	var randPosX = rand_range(-13,13)
	t.translation = Vector3(randPosX,56.897,0)
	add_child(t)















