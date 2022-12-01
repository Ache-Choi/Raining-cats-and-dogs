extends Spatial

onready var carCont = $meshCont
onready var  carMesh = $meshCont/car
onready var rayFront = $meshCont/frontRay
onready var rayBack = $meshCont/backRay
onready var colPos = $meshCont/Area/CollisionShape
onready var frontWheel = $meshCont/whelFront
onready var backWheel = $meshCont/wheelBack
onready var animPlayere = $AnimationPlayer
onready var backLight = $meshCont/car/stopLight
onready var carAnim = $meshCont/car/carAnim
onready var tween1 = $Tween
onready var tween2 = $Tween2
onready var tween3 = $Tween3
onready var fx1 = $meshCont/savedFxBasket/fx1
onready var fx2 = $meshCont/savedFxBasket/fx2
onready var savedFx = $savedFx

var speedFix = 20
var speed = 20
var canMove = false
# animation player vehiclee movement

func _ready():
	speedFix = GVariables.carSpeed
	speed = GVariables.carSpeed
	set_material()
	backLight.material_override.flags_unshaded =  true
	backLight.material_override.albedo_color = 'ff0000'
	carAnim.play("carStart")
	yield(get_tree().create_timer(1),"timeout")
	canMove = true

func set_material():
	var mat = load('res://scenes/spriteEffects/savedFxAssets/savedFx.tres').duplicate()
	mat.set('albedo_color','14d3ff')
	fx1.material_override = mat
	
	var mat2 = load('res://scenes/spriteEffects/savedFxAssets/savedFx.tres').duplicate()
	mat2.set('albedo_color','ffe900')
	fx2.material_override = mat2

func _process(delta):
	if canMove:
		player_dir_move(delta)

func move_right_left(rightLeft):
	if rightLeft == 'right':
		backLight.material_override.flags_unshaded =  false
		backLight.material_override.albedo_color = 'ff7a7a' 
		animPlayere.play("wheel")
		tween_rot(tween1, carMesh.rotation_degrees, Vector3(0,180,5), .1)
	elif rightLeft == 'left':
		backLight.material_override.flags_unshaded =  false
		backLight.material_override.albedo_color = 'ff7a7a' 
		animPlayere.play_backwards("wheel")
		tween_rot(tween1, carMesh.rotation_degrees, Vector3(0,180,-5), .1)
	else:
		backLight.material_override.flags_unshaded =  true
		backLight.material_override.albedo_color = 'ff0000'
		animPlayere.stop()
		tween_rot(tween1, carMesh.rotation_degrees, Vector3(0,180,0), .1)
		
var switchL = 0
var switchR = 0
func player_dir_move(delta):
	if Input.is_action_pressed("right"):
		if rayBack.is_colliding():
			speed =  lerp(speed, 0, 0.1)
		else:
			speed =  lerp(speed, speedFix, 0.2)
			
		if switchR == 0:
			switchR = 1
			move_right_left('right')
		carCont.translation.x -= speed * delta
	if Input.is_action_just_released("right"):
		switchR = 0
		move_right_left('stop')


	if Input.is_action_pressed("left"):
		if rayFront.is_colliding():
			speed =  lerp(speed, 0, 0.1)
		else:
			speed =  lerp(speed, speedFix, 0.2)
		if switchL == 0:
			switchL = 1
			move_right_left('left')
		carCont.translation.x += speed * delta

	if Input.is_action_just_released("left"):
		switchL = 0
		move_right_left('stop')

	if Input.is_action_pressed("right") and Input.is_action_just_pressed("left"):
		switchL = 1
		switchR = 1
		move_right_left('stop')
	if Input.is_action_pressed("left") and Input.is_action_just_pressed("right"):
		switchL = 1
		switchR = 1
		move_right_left('stop')

	if Input.is_action_pressed("right") and Input.is_action_just_released("left"):
		move_right_left('right')
	if Input.is_action_pressed("left") and Input.is_action_just_released("right"):
		move_right_left('left')

	if carCont.translation.x <= -12:
		carCont.translation.x = -12
	if carCont.translation.x >= 12:
		carCont.translation.x = 12

func tween_rot(nod, from, to, tim):
#	var tweenArr = [Tween.TRANS_QUAD, Tween.TRANS_QUART, Tween.TRANS_QUINT]
	nod.interpolate_property(carMesh, 'rotation_degrees', from, to, tim, Tween.TRANS_QUAD,Tween.EASE_OUT)
	nod.start()

func _on_Area_body_entered(body):
	if body.is_in_group('animalDrop'):
		var num = floor(rand_range(1,5))
		GSignals.inst_sounds('caughtAnim%s'%num)
		GVariables.savedCounts2F += 1
		GSignals.update_ui_count(1,0)
		body.queue_free()
		savedFx.play("saved")
		GSignals.inst_items('savedStarFx', colPos.global_transform.origin, 'positive',0)
	if body.is_in_group('iceDrop'):
		GSignals.inst_sounds('iceCaught')
		GSignals.inst_sounds('negativeCaught')
		GVariables.iceDrops += 1
		GSignals.inst_items('noSavedStarFx', colPos.global_transform.origin, 'negative',0)
		savedFx.play("iceDrop")
		body.queue_free()



func _on_Area_area_entered(area):
	if area.is_in_group('thunderStrike'):
		GVariables.lightningHitNet +=1
		GSignals.inst_items('noSavedStarFx', colPos.global_transform.origin, 'negative',0)
		savedFx.play("iceDrop")
#		print('thunder sttrike car')
