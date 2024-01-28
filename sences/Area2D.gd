extends Area2D

var isPanelOpen = false
var isDrag = false
var setNode: Button
func _ready():
	var parent = get_parent()
	setNode = parent.get_node("setting_btn")
	setNode.visible=false
	pass

func _process(delta):
	if isDrag:
		self.position = get_global_mouse_position()
		$pet.play('drag')
	
func _input(event):
	# if mouse just come to this area we can enter to setting page
	if event is InputEventMouseMotion:
		if event.relative>Vector2.ONE && !isPanelOpen:
			await get_tree().create_timer(0.5, false).timeout
			setNode.visible=true
			#print(setNode.visible)
			# give a timer to make 1 sec duration becuase too fast
			await get_tree().create_timer(2, false).timeout
			setNode.visible=false
		pass
	if event is InputEventMouseButton:
		if event.button_index==MOUSE_BUTTON_LEFT and event.pressed:
			isDrag = true
		else:
			isDrag = false

