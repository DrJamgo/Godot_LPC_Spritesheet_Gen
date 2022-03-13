extends Resource
class_name LPCSpriteFactory

var all_json_list := {}
var all_json_tree := {}
var all_typename_list := {}
var selected_typename_list := {}

export(String) var rootpath = self.get_script().get_path().get_base_dir() + "/lpc_spritesheets/"
export(String) var dest_path = "res://assets/lpc_spritesheets/"

export(String, 'male', 'female', 'child', 'pregnant', 'muscular') var body_type := 'male'

func _init():
    all_json_list = _loadJsonFiles()
    all_json_tree = _getNodes(all_json_list.keys(), "")
    pass
    
func _loadJsonFiles():
    print("_loadJsonFiles")
    var dict = {}

    var dir = Directory.new()
    var definitions_path = rootpath + "/sheet_definitions/"
    if dir.open(definitions_path) == OK:
        dir.list_dir_begin(true, true)
        var file_name = dir.get_next()
        while file_name != "":
            if !dir.current_is_dir() and file_name.ends_with('.json'):
                var file = File.new()
                file.open(definitions_path + file_name, file.READ);
                var text = file.get_as_text()
                var json_result = JSON.parse(text)
                file.close()
                if json_result.error == OK:
                    dict[file_name.get_basename().replace('_','/')] = json_result.result

            file_name = dir.get_next()
    print(String(dict.keys().size()) + " JSON files found")
    return dict

func _getNodes(keys: Array, location: String):
    var list = {}
    while keys.size() != 0:
        var key = keys[0]
        var last_ = key.find_last('/')
        var nodename = key.substr(last_+1)
        if key.begins_with(location) and location.length() > last_:
            ## corrent place
            var skip = false
            if all_json_list.has(key):
                var json_data = all_json_list[key]
                var typename = json_data.type_name
                if not typename in all_typename_list:
                    all_typename_list[typename] = null
                if !json_data.layer_1.has(body_type):
                    skip = true
            if !skip:
                list[nodename] = key
            keys.remove(0)

        elif key.begins_with(location):
            ## lets add a level
            var new_location = String(location)
            var numLevels = new_location.split('/',true).size()-1
            var new_level = key.split('/')[numLevels] + "/"
            if numLevels > 0:
                new_location += new_level
            else:
                new_location = new_level
            var children = _getNodes(keys, new_location)
            if children:
                list[new_level] = children
        else:
            ## too far, lets exit
            match list.keys().size():
                0:
                    return null
                #1:
                #    return list[list.keys()[0]]
                _:
                    return list
    return list

func get_lpc_layers(base : String, variant : String) -> Array:
    var layers := []
    var json_data : Dictionary = all_json_list[base]
    var layer_idx := 1
    while true:
        var layername = "layer_" + String(layer_idx)
        if not json_data.has(layername):
            break
        var relpath = json_data.layer_1[body_type] + variant + ".png"
        var new_layer = LPCSpriteLayer.new()
        new_layer.json_data = json_data
        new_layer.body = body_type
        new_layer.name = json_data.name
        new_layer.type_name = json_data.type_name
        new_layer.zorder = json_data[layername].zPos
        new_layer.rel_path = (json_data[layername][body_type] + variant + ".png").replace(' ','_')
        new_layer.abs_path = dest_path + new_layer.rel_path
        new_layer.variant = variant
        layers.append(new_layer)
        layer_idx += 1
    return layers
    
func load_texture(layer : LPCSpriteLayer) -> bool:
    var resource_exists = layer.load_texture()
    if not resource_exists:
        # load image texture from Disk
        #var image = Image.new()
        #image.load(rootpath + 'spritesheets/' + layer.rel_path)
        #var texture = ImageTexture.new()
        #texture.create_from_image(image)
        #layer.texture = texture
        
        # copy file to new location
        var dir = Directory.new()
        dir.make_dir_recursive(layer.abs_path.get_base_dir())
        dir.copy(rootpath + 'spritesheets/' + layer.rel_path, layer.abs_path)
        
    return resource_exists
