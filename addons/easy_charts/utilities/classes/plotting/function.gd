extends RefCounted
class_name Function

enum Type {
	SCATTER,
	LINE,
	AREA,
	PIE,
	BAR
}

enum Interpolation {
	NONE,
	LINEAR,
	STAIR,
	SPLINE
}

# TODO: add new markers, like an empty circle, an empty box, etc.
enum Marker {
	NONE,
	CIRCLE,
	TRIANGLE,
	SQUARE,
	CROSS
}

var x: Array
var y: Array
var name: String
var props: Dictionary = {
	color = null,
	marker = null,
	gradient = null,
	type = null,
	interpolation = null,
	line_width = null,
	point_size = null
}

func _init(x: Array, y: Array, name: String = "", props: Dictionary = {}) -> void:
	self.x = x.duplicate()
	self.y = y.duplicate()
	self.name = name
	if not props.is_empty() and props != null:
		self.props = props

func add_point(x: float, y: float) -> void:
	self.x.append(x)
	self.y.append(y)

func get_color() -> Color:
	return props.get("color", Color("#222222"))

func get_gradient() -> Gradient:
	return props.get("gradient", Gradient.new())

func get_marker() -> int:
	return props.get("marker", Marker.NONE)

func get_type() -> int:
	return props.get("type", Type.SCATTER)

func get_interpolation() -> int:
	return props.get("interpolation", Interpolation.LINEAR)

func get_line_width() -> float:
	return props.get("line_width", 2.0)

func get_point_size() -> float:
	return props.get("point_size", 2.0)

func _to_string() -> String:
	return "Function: %s %s\n" % [name, props]
