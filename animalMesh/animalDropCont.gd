extends RigidBody

export (int) var animalType

onready var animSprite = $AnimatedSprite3D
onready var particles = $CPUParticles


func _ready():
	if animalType == 0:
		animSprite.play("dogDrop")
	else:
		animSprite.play("catDrop")
	particles.emitting = true

#func _process(delta):
#	print(self.rotation_degrees, '            ', animSprite.rotation_degrees)
	
#	if self.rotation_degrees.z != 0:
#		self.rotation_degrees.z = 0
#
#	if self.global_transform.origin.z  != 0:
#		self.global_transform.origin.z = 0
		
		

func _on_Area_body_entered(body):
	if body.name != self.name:
		if body.is_in_group('staticFloor'):
			GSignals.inst_sounds('animDropSplat')
			GSignals.inst_ground_explode('animalGroundExplode', self.global_transform.origin, 0, 0)
			self.queue_free()
		if body.is_in_group('animalDrop') or  body.is_in_group('iceDrop'):
			var num = floor(rand_range(1,5))
			GSignals.inst_sounds('dropContact%s'%num)
			if body.global_transform.origin.x >= self.global_transform.origin.x:
				GSignals.inst_contact_fx('dropContact', self.global_transform.origin + Vector3(1,0,0), 'center', 0)
			else:
				GSignals.inst_contact_fx('dropContact', self.global_transform.origin + Vector3(-1,0,0), 'center', 0)
		if body.is_in_group('staticWall'):
			var num = floor(rand_range(1,5))
			GSignals.inst_sounds('dropContact%s'%num)
			if self.global_transform.origin.x >= 0:
				GSignals.inst_contact_fx('sideContact', self.global_transform.origin, 'left', 0)
			else:
				GSignals.inst_contact_fx('sideContact', self.global_transform.origin, 'right', 0)
		if body.is_in_group('netCarStatic'):
			var num = floor(rand_range(1,5))
			GSignals.inst_sounds('dropContact%s'%num)
			GSignals.inst_contact_fx('dropContact', self.global_transform.origin + Vector3(0,-1,0), 'center', 0)

