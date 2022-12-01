extends Node

onready var audioStream = $AudioStreamPlayer
onready var animPlayer = $AnimationPlayer

var bgmPathArr = ['res://assets/soundMusic/music/1.wav',
				  'res://assets/soundMusic/music/2.wav',
				  'res://assets/soundMusic/music/3.wav',
				  'res://assets/soundMusic/music/4.wav',
				  'res://assets/soundMusic/music/5.wav'
				]
var ddbuug
func _ready():
	audioStream.stream = load(bgmPathArr[GVariables.currentLevel])
	ddbuug = GSignals.connect('stopBgm', self, 'stop_bgm')
	animPlayer.play("playBGM")

func stop_bgm():
	animPlayer.play("stopBGM")
