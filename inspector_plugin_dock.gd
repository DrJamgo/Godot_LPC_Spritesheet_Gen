tool
extends VBoxContainer

const rootpath = "res://addons/lpc_spritesheet_gen/lpc_spritesheets"
const dst_base_path = "res://assets/lpc_spritesheets/"

var editor_interface : EditorInterface
var blueprint : LPCSpriteBlueprint setget set_blueprint

onready var http_node := $CanvasLayer/HTTPRequest

signal _web_files_downloaded()

func set_blueprint(_blueprint : LPCSpriteBlueprint):
	blueprint = _blueprint
	($vpc/vp/sprite_down as LPCSprite).set_dir(Vector2(0,1))
	($vpc/vp/sprite_up as LPCSprite).set_dir(Vector2(0,-1))
	($vpc/vp/sprite_left as LPCSprite).set_dir(Vector2(-1,0))
	($vpc/vp/sprite_right as LPCSprite).set_dir(Vector2(1,0))
	for sprite in $vpc/vp.get_children():
		(sprite as LPCSprite).frames = blueprint
		(sprite as LPCSprite).set_anim($bodytypes/animation.text)
		(sprite as LPCSprite).playing = true
	_load_from_blueprint()

func _enter_tree():
	if !blueprint:
		set_blueprint(LPCSpriteBlueprint.new())   

func _add_layers_item(index : int, layer : LPCSpriteBlueprintLayer):
	var props = ['zorder', 'type_name', 'rel_path']
	var text = ""
	for prop in props:
		text += " ; " + String(layer[prop])

func _on_layers_item_activated(index):
	(blueprint as LPCSpriteBlueprint).remove_layer(index)
	_load_from_blueprint()

func _load_from_blueprint():
	if blueprint:
		for index in range(0, blueprint.layers.size()):
			var meta = (blueprint.layers[index] as LPCSpriteBlueprintLayer)
			_add_layers_item(index, blueprint.layers[index])

func _set_animation(animname : String):
	for sprite in $vpc/vp.get_children():
		var suffix = sprite.name.split('_')[1]
		var anim = animname + "_" + suffix
		if sprite.frames.has_animation(anim):
			sprite.play(anim)
		else:
			sprite.play('idle_'+suffix)

func _on_animation_item_selected(index):
	var animname = $bodytypes/animation.get_item_text(index)
	_set_animation(animname)

func _download_spritesheets_from_web(base_url : String, layers : Array):
	var downloaded_files = []
	for layer in layers:
		var local_path = dst_base_path + layer["fileName"]
		if not File.new().file_exists(local_path):
			var layer_web_url = base_url + layer["fileName"]
			var dir = Directory.new()
			dir.make_dir_recursive(local_path.get_base_dir())
			http_node.download_file = local_path
			http_node.request(layer_web_url)
			yield(http_node, "request_completed")
			downloaded_files.push_back(local_path)
	
	yield(get_tree(), "idle_frame")
	if downloaded_files.size() > 0:
		var filesystem := editor_interface.get_resource_filesystem()
		print("Rescan..")
		filesystem.scan()
		yield(filesystem, "resources_reimported")
		print(".. rescan finished!")
		yield(get_tree(), "idle_frame")
		
	emit_signal("_web_files_downloaded")

func _on_ButtonImport_pressed():
	var clipboard_content := OS.get_clipboard()
	var jsonResult := JSON.parse(clipboard_content)
	var fs := editor_interface.get_resource_filesystem()
	if jsonResult.error == OK and jsonResult.result is Dictionary:
		var data : Dictionary = jsonResult.result
		_download_spritesheets_from_web(data["spritesheets"], data["layers"])
		print("Wait for downlaods..")
		yield(self, "_web_files_downloaded")
		print(".. download finished!")
		var new_layers = []
		for layer in data["layers"]:
			var local_path = dst_base_path + layer["fileName"]
			var new_layer := LPCSpriteBlueprintLayer.new()
			new_layer.zorder = int(layer["zPos"])
			new_layer.rel_path = layer["fileName"]
			new_layer.abs_path = local_path
			new_layer.body = data["bodyTypeName"]
			new_layer.type_name = layer["parentName"]
			new_layer.name = layer["name"]
			new_layer.variant = layer["variant"]
			if layer.has("custom_animation"):
				match(layer["custom_animation"]):
					"slash_oversize":
						new_layer.oversize_animation = "slash"
					"thrust_oversize":
						new_layer.oversize_animation = "thrust"
					_:
						print("custom_animation '" + str(layer["custom_animation"]) + "' not supported!")
				
			new_layers.append(new_layer)
			new_layer.load_texture()
			
		blueprint.layers.clear()
		blueprint.add_layers(new_layers)
		yield(get_tree(), "idle_frame")
		blueprint.source_url = data["url"]
		
	_load_from_blueprint()

func _on_ButtonOpen_pressed():
	if blueprint.source_url != "":
		OS.shell_open(blueprint.source_url)
	else:
		OS.shell_open("http://127.0.0.1:5500/index.html")
