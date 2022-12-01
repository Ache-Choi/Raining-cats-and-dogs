extends Spatial

var res_loader : ResourceInteractiveLoader = null
var loading_thread : Thread = null

#signal quit
#warning-ignore:unused_signal
signal replace_main_scene # Useless, but needed as there is no clean way to check if a node exposes a signal

var ddbuug

func _ready():
	pass

func change_scene():
	var path = GVariables.nextScenePath
	yield(get_tree().create_timer(.5),"timeout")
	emit_signal("replace_main_scene", ResourceLoader.load(path))

