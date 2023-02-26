## Copyright (C) 2023 Denis Selensky - All Rights Reserved
## You may use, distribute and modify this code under the terms of the MIT license

tool
extends VBoxContainer

var dst_base_path = "res://assets/lpc_sprites/"

var editor_interface : EditorInterface
var blueprint : LPCSpriteBlueprint setget set_blueprint

onready var http_node := $CanvasLayer/HTTPRequest

signal _web_files_downloaded()

func set_blueprint(_blueprint : LPCSpriteBlueprint):
	blueprint = _blueprint
	for sprite in $vpc/vp.get_children():
		(sprite as LPCSprite).frames = blueprint
		_set_animation($bodytypes/animation.text)
		(sprite as LPCSprite).playing = true
	_load_from_blueprint()

func _enter_tree():
	if !blueprint:
		set_blueprint(LPCSpriteBlueprint.new())

func _update_credits_text():
	var missing_text = "!MISSING LICENSE INFORMATION!"
	$CreditsLabel.bbcode_text = blueprint.credits_txt
	$CreditsLabel.bbcode_text = $CreditsLabel.bbcode_text.replace(missing_text, "[color=red]" + missing_text + "[/color]")
	
	var licenses := {
			"CC0":"https://creativecommons.org/publicdomain/zero/1.0/",
			"CC-BY-SA 3.0":"https://creativecommons.org/licenses/by-sa/3.0",
			"CC BY 3.0":"https://creativecommons.org/licenses/by/3.0",
			"CC-BY 3.0":"https://creativecommons.org/licenses/by/3.0",
			"CC-BY 4.0":"https://creativecommons.org/licenses/by/4.0",
			"OGA-BY 3.0":"https://static.opengameart.org/OGA-BY-3.0.txt",
			"GPL 1.0":"https://www.gnu.org/licenses/gpl-1.0.en.html",
			"GPL 2.0":"https://www.gnu.org/licenses/gpl-2.0.en.html",
			"GPL 3.0":"https://www.gnu.org/licenses/gpl-3.0.en.html",
		}
		
	for lic in licenses:
		$CreditsLabel.bbcode_text = $CreditsLabel.bbcode_text.replace(lic, "[url="+licenses[lic]+"]"+lic+"[/url]")

func _on_meta_clicked(meta : String):
	if meta.begins_with("res://"):
		var path = ProjectSettings.globalize_path(meta)
		OS.shell_open(path)
	else:
		OS.shell_open(meta)

func _load_from_blueprint():
	$LayersList.bbcode_text = "[table=3][cell]Z[/cell][cell]Type[/cell][cell]File path[/cell]"
	$CreditsLabel.bbcode_text = ""
	if blueprint:
		_update_credits_text()
		for index in range(0, blueprint.layers.size()):
			var meta := (blueprint.layers[index] as LPCSpriteBlueprintLayer)
			var format_string = '[cell]{z}[/cell] [cell]{t}[/cell] [cell][url={url}]{rp}[/url][/cell]\n'
			$LayersList.bbcode_text += format_string.format({"z":meta.zorder, "t":meta.type_name, "rp":meta.rel_path, "url":meta.rel_path})
			
	$LayersList.bbcode_text += "[/table]"

func _set_animation(animname : String):
	for sprite in $vpc/vp.get_children():
		var suffix = sprite.name.split('_')[1]
		(sprite as LPCSprite).set_dir(suffix)
		(sprite as LPCSprite).set_anim(animname)

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
		blueprint.credits_txt = str(data["credits"])

	_load_from_blueprint()

func _on_ButtonOpen_pressed():
	if blueprint.source_url != "":
		OS.shell_open(blueprint.source_url)
	else:
		OS.shell_open("https://sanderfrenken.github.io/Universal-LPC-Spritesheet-Character-Generator/")

func _on_LayersList_meta_clicked(meta):
	var tween = get_tree().create_tween()
	tween.set_parallel()
	for sprite in $vpc/vp.get_children():
		var layers = sprite.get_layers()
		for layer in layers:
			var bp_layer = ((layer as LPCSpriteLayer).blueprint_layer as LPCSpriteBlueprintLayer)
			if bp_layer.rel_path == meta:
				tween.tween_method(layer, "set_highlight", Color(1,1,1,1), Color(0,0,0,0), 0.5)
				tween.tween_method(layer, "set_outline", Color(1,0,0,1), Color(1,0,0,0), 0.5)


func _on_ReplayButton_pressed():
	for sprite in $vpc/vp.get_children():
		sprite.frame = 0

func _on_ReloadButton_pressed():
	if blueprint:
		_load_from_blueprint()
		blueprint.emit_changed()
