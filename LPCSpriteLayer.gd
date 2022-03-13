tool
extends Resource
class_name LPCSpriteLayer

export(int) var zorder := 10
export(Dictionary) var json_data = {}
export(String) var body := "male"     # Type of Body
export(String) var name := "Template" # From JSON Data
export(String) var type_name := "body" # From JSON Data
export(String) var variant = "0" # From Selection
export(String) var abs_path := ""
export(String) var rel_path := ""
export(Texture) var texture setget ,get_texture

func load_texture() -> bool:
    var resource_exists = ResourceLoader.exists(abs_path)
    print(abs_path + " exists? " + String(resource_exists))
    if resource_exists and not texture:
        print("explicit loading from " + abs_path)
        texture = load(abs_path)
        emit_changed()
    return resource_exists

func get_texture():
    if !texture:
        load_texture()
    return texture
    
func _init():
    if abs_path != "":
        print("_init loading from " + abs_path)
        texture = load(abs_path)

func randomize_variant(variants : Array = []):
    if variants.size() == 0:
         variants = json_data.variants
    var numVariants = variants.size()
    var index = randi() % numVariants
    var v = variants[index]
    rel_path = rel_path.replace(variant+'.png',v+'.png').replace(' ','_')
    abs_path = abs_path.replace(variant+'.png',v+'.png').replace(' ','_')
    variant = v
    texture = load(abs_path)
