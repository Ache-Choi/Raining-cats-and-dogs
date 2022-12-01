extends RigidBody

onready var particles = $CPUParticles


func _ready():
	particles.emitting = true


func _on_Area_body_entered(body):
	if body.name != self.name:
		if body.is_in_group('staticFloor'):
			GSignals.inst_sounds('iceSplat')
			GSignals.inst_sounds('animDropSplatLow')
			GSignals.inst_ground_explode('iceGroundExplode', self.global_transform.origin, 0, 0)
			self.queue_free()
		if body.is_in_group('animalDrop') or  body.is_in_group('iceDrop'):
			if body.global_transform.origin.x >= self.global_transform.origin.x:
				GSignals.inst_contact_fx('dropContact', self.global_transform.origin + Vector3(1,0,0), 'center', 0)
			else:
				GSignals.inst_contact_fx('dropContact', self.global_transform.origin + Vector3(-1,0,0), 'center', 0)
		if body.is_in_group('staticWall'):
			if self.global_transform.origin.x >= 0:
				GSignals.inst_contact_fx('sideContact', self.global_transform.origin, 'left', 0)
			else:
				GSignals.inst_contact_fx('sideContact', self.global_transform.origin, 'right', 0)
		if body.is_in_group('netCarStatic'):
			var num = floor(rand_range(1,5))
			GSignals.inst_sounds('dropContact%s'%num)
			GSignals.inst_contact_fx('dropContact', self.global_transform.origin + Vector3(0,-1,0), 'center', 0)
