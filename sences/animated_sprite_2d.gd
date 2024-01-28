extends Node2D

var pet: AnimatedSprite2D 
var setPanel: TabContainer
const PETPATH = 'res://pets'
const PETPATHUSER = 'user://pets/'
# dict to store a button and spriteFrame
var petList = {}
var petPool = GridContainer
@onready var fileDia = $settingPanel/addNewPet/filedialog
@onready var parent = $Area2D
var removePetBt: Button
var fileTran: FileTransform
# Called when the node enters the scene tree for the first time.
func _ready():
	## test instance button
	#var btTst = Button.new()
	#btTst.pressed.connect(self._button_pressed)
	#btTst.text = 'test button '
	#petList[btTst] = 'aadd'
	#print(btTst == self)
	#add_child(btTst)
	
	get_tree().root.set_transparent_background(true)
	pet = get_node("Area2D/pet")
	setPanel = get_node("settingPanel")
	petPool = $"settingPanel/pets pool"
	removePetBt = $"settingPanel/pets pool/removePetBt"
	## create a button for each pet option
	getPetsFromFile(PETPATH)
	getPetsFromFile(PETPATHUSER)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _input(event):
	# when click play click anime
	if event is InputEventMouseButton:
		#pet.stop()
		if event.button_index == MOUSE_BUTTON_RIGHT && event.pressed:
			pet.play('click')
			#print('change anime\t'+ Time.get_datetime_string_from_system())	
		if !event.pressed:
			pet.play('idel')

#class to send data to label
class FileTransform:
	var _fromEnd: TextEdit
	var _fileDia: FileDialog
	
	func _init(fileDia, from):
		_fileDia = fileDia
		_fromEnd = from
		
	func sendDataToEnd(path):
		_fromEnd.text = ''
		for item in path:
			_fromEnd.text += str(item)
			_fromEnd.text += ','
		print('path from FileTransform path are: '+ _fromEnd.name)
		print('split str: '+ str(_fromEnd.text.rsplit(',')))

func _on_setting_btn_pressed():
	setPanel.visible = true
	parent.isPanelOpen = true
	# update pet pool
	flushPets()
	getPetsFromFile(PETPATH)
	getPetsFromFile(PETPATHUSER)
	setPanel.current_tab = 0
	pass # Replace with function body.

func _on_close_x_pressed():
	setPanel.visible = false
	parent.isPanelOpen = false
	pass # Replace with function body.
# change sprite frame
func _button_pressed(btTxt: String):
	# change pet style
	pet.set_sprite_frames(petList[btTxt])
	pet.play('idel')
	#print('now pet is: '+btTxt)

func _on_idel_staus_bt_pressed():
	fileDia.popup()
	fileTran = FileTransform.new(fileDia, $settingPanel/addNewPet/idelStausLal)
	pass # Replace with function body.

func _on_filedialog_files_selected(paths):
	fileTran.sendDataToEnd(paths)
	#print('paths: '+ str(paths) +' request from: ')

func _on_click_staus_bt_pressed():
	fileDia.popup()
	fileTran = FileTransform.new(fileDia, $settingPanel/addNewPet/clickStausLal)
	pass # Replace with function body.

func _on_drag_staus_bt_pressed():
	fileDia.popup()
	fileTran = FileTransform.new(fileDia, $settingPanel/addNewPet/dragStausLal)
	pass # Replace with function body.

func _on_upload_pressed():
	# materials path
	var idelData = $settingPanel/addNewPet/idelStausLal.text.rsplit(',', true)
	var clickData = $settingPanel/addNewPet/clickStausLal.text.rsplit(',', true)
	var dragData = $settingPanel/addNewPet/dragStausLal.text.rsplit(',', true)
	idelData.remove_at(idelData.size()-1)
	clickData.remove_at(clickData.size()-1)
	dragData.remove_at(dragData.size()-1)
	# name must have
	if $settingPanel/addNewPet/petNameEdTxt.text == '':
		var empName = AcceptDialog.new()
		$settingPanel/addNewPet.add_child(empName)
		empName.dialog_text = 'no name for upload pet. please add one!'
		empName.popup_centered()
		empName.confirmed.connect(self._on_pressed_conform.bind(empName))
		return
	# frame -> anime -> spriteFrame
	var newFrame = SpriteFrames.new()
	if addNewAni('idel', idelData, newFrame) && addNewAni('click', clickData, newFrame):
		if addNewAni('drag', dragData, newFrame):
		# save sprite frame in user://
		# input name for newFrame
		# create a dir for saving
			ResourceSaver.save(newFrame, PETPATHUSER+$settingPanel/addNewPet/petNameEdTxt.text+'.tres')
			for c in petPool.get_children():
				petPool.remove_child(c)
			OS.alert('You have add new pet.', 'Information')
	else:
		newFrame = null
			
func addNewAni(aniName: String, frameList, spriteFrame: SpriteFrames)->bool:
	if aniName not in spriteFrame.get_animation_names():
		spriteFrame.add_animation(aniName)
	for item in frameList:
		print(item)
		if Image.new().load(item)==OK && item!='':
			spriteFrame.add_frame(aniName, ResourceLoader.load(item))
		else:
			var uploadFramesDia = AcceptDialog.new()
			uploadFramesDia.dialog_text = 'load images failed please check the format(PNG, JPG) or directory is empty.'
			uploadFramesDia.confirmed.connect(self._on_pressed_conform.bind(uploadFramesDia))
			$settingPanel/addNewPet.add_child(uploadFramesDia)
			spriteFrame.clear(aniName)
			return false
	spriteFrame.set_animation_loop(aniName, true)
	return true
	
func _on_pressed_conform(input):
	#print('come to confirm func')
	input.queue_free()
	pass
	
func getPetsFromFile(path: String):
	if !ResourceLoader.exists(path):
		DirAccess.make_dir_absolute(path)
	# create a button for each pet option
	for item in DirAccess.get_files_at(path):
		# remap is a runtime file type when export resource files
		if item.get_extension()=='tres' || item.get_extension()=='remap':
			item = item.replace('.remap', '')
			var petRes = ResourceLoader.load(path+'/'+item)
			var petBtn = Button.new()
			petBtn.set_toggle_mode(true) 
			# event click button can change spriteFrame to pet
			petBtn.text = str(item.get_file())
			# event to do something
			petBtn.pressed.connect(self._button_pressed.bind(petBtn.text))
			petBtn.button_up.connect(self._button_up.bind(petBtn.text))
			#petBtn.toggled.connect(self._button_toggled.bind(petBtn.text))
			petPool.add_child(petBtn)
			petList[petBtn.text] = petRes

func _button_up(btTxt):
	if btTxt == '':
		OS.alert('no pet select to remove.')
	else:
		var removeDia = AcceptDialog.new()
		removeDia.confirmed.connect(self.removePet.bind(btTxt))
		removeDia.dialog_text = 'Do you want to remove this pet? ( '+ btTxt +' )'
		removeDia.add_cancel_button('cancel')
		removeDia.canceled.connect(self._on_pressed_conform.bind(removeDia))
		petPool.add_child(removeDia)
		removeDia.popup_centered()
	pass
	
func flushPets():
	var children = $"settingPanel/pets pool".get_children()
	for item in children:
		item.queue_free()

# remove pet form pet pool
func removePet(btTxt: String):
	var bt = petList[btTxt]
	# delete directory
	var path = PETPATHUSER+btTxt
	print('log: path is >' + path)
	var pathExport = path+'.remap'
	if ResourceLoader.exists(path+'/'):
		DirAccess.remove_absolute(path)
		flushPets()
		getPetsFromFile(PETPATH)
		getPetsFromFile(PETPATHUSER)
		var retDia = AcceptDialog.new()
		retDia.dialog_text = 'you have remove this pet ( '+ btTxt +' ) from pet pool.'
		petPool.add_child(retDia)
		retDia.popup_centered()
		retDia.confirmed.connect(self._on_pressed_conform.bind(retDia))
	elif ResourceLoader.exists(pathExport):
		DirAccess.remove_absolute(pathExport)
		flushPets()
		getPetsFromFile(PETPATH)
		getPetsFromFile(PETPATHUSER)
		var retDia = AcceptDialog.new()
		retDia.dialog_text = 'you have remove this pet ( '+ btTxt +' ) from pet pool.'
		petPool.add_child(retDia)
		retDia.popup_centered()
		retDia.confirmed.connect(self._on_pressed_conform.bind(retDia))
	else:
		var retDia = AcceptDialog.new()
		retDia.dialog_text = "remove failed. it might can't be delete because it's system pet."
		petPool.add_child(retDia)
		retDia.popup_centered()
		retDia.confirmed.connect(self._on_pressed_conform.bind(retDia))
	pass

#func _button_toggled(isToggled, btTxt):
	##if isToggled:
		###print('is toggle'+btTxt)
		###removePetBt.pressed.connect(_button_up.bind(btTxt))
	##else:
		##print('no toggle')
		#pass
	





