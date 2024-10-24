extends Object
class_name GbmUtils

static func get_dialogue(keys: Array[String]) -> Array[Array]:
	var dial: Array[Array]
	var instance: Object = new()
	for i in keys.size():
		dial.append(str_to_var(instance.tr(keys[i])))
	return dial
