extends Node
class_name ProceduralGenerator

# ------------------------------------------------------------------------------
class Noise:
	var _noise = OpenSimplexNoise.new()
	var _params = {
		"split": 0.489,
		"sign": true,
	}
	
	var _properies = [
			{ name = "octaves", hint = PROPERTY_HINT_RANGE, hint_string = "1,9,1", type = TYPE_REAL },
			{ name = "period", hint = PROPERTY_HINT_RANGE, hint_string = "0,500", type = TYPE_REAL },
			{ name = "lacunarity", hint = PROPERTY_HINT_RANGE, hint_string = "0,5", type = TYPE_REAL },
			{ name = "persistence", hint = PROPERTY_HINT_RANGE, hint_string = "0,5", type = TYPE_REAL },
			{ name = "split", hint = PROPERTY_HINT_RANGE, hint_string = "0,1", type = TYPE_REAL },
			{ name = "sign", type = TYPE_BOOL },
		]
	
	# --------------------------------------------------------------------------
	func _get_property_list():
		return _properies
	
	# --------------------------------------------------------------------------
	func _set(property, value):
		if _params.has(property):
			_params[property] = value
		else:
			_noise.set(property, value)
	
	# --------------------------------------------------------------------------
	func _get(property):
		if _params.has(property):
			return _params[property]
		else:
			return _noise.get(property)


# ------------------------------------------------------------------------------
var noise_seed = 0

# ------------------------------------------------------------------------------
func _get_property_list():
	var props = [
		{ name = "randomize_seed", type = TYPE_BOOL },
		{ name = "clear", type = TYPE_BOOL },
	]

	var noise_dict = _get_noise_dict()
	for noise_name in noise_dict.keys():
		var p_list = noise_dict[noise_name].get_property_list()

		for p in p_list:
			props.append(p)
			props.back().name = noise_name + "/" + props.back().name

	return props


# ------------------------------------------------------------------------------
func _set(property : String, value):
	var split = property.split("/")

	if split.size() == 2:
		var noise_name = property.split("/")[0]
		var prop_name = property.split("/")[1]

		var noise_dict = _get_noise_dict()
		if noise_dict.has(noise_name):
			noise_dict[noise_name]._set(prop_name, value)
		
		generate()
		
	elif Engine.editor_hint:
		if property == "clear":
			clear()
			
		else:
			if property == "randomize_seed":
				noise_seed = randi()
				
			generate()


# ------------------------------------------------------------------------------
func _get(property):
	var split = property.split("/")

	if split.size() == 2:
		var noise_name = property.split("/")[0]
		var prop_name = property.split("/")[1]

		var noise_dict = _get_noise_dict()
		if noise_dict.has(noise_name):
			return noise_dict[noise_name]._get(prop_name)


# ------------------------------------------------------------------------------
func _get_noise_dict() -> Dictionary:
	print_debug("No '_get_noise_dict' method defined for procedural generator.")
	return {}
	

# ------------------------------------------------------------------------------
func clear():
	print_debug("No 'clear' method defined for procedural generator.")


# ------------------------------------------------------------------------------
func generate():
	print_debug("No 'generate' method defined for procedural generator.")


# ------------------------------------------------------------------------------
