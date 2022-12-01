extends Node2D


func _ready():
	$AnimationPlayer.play("timesUp")


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == 'timesUp':
		$AnimationPlayer.play("closeWind")
	if anim_name == 'closeWind':
		GSignals.change_scene_signal()
		GSignals.inst_sounds('winClose')

