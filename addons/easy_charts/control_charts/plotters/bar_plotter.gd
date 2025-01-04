extends FunctionPlotter
class_name BarPlotter


signal point_entered(point, function)
signal point_exited(point, function)

# var function

var bars: PoolVector2Array
var bars_rects: Array
var focused_bar_midpoint: Point

var bar_ratio_size: float
var bar_alignment: int
var histogram_width: float

# func _init(function: Function).(function) -> void:

# func _init():


func set_function(_function):
	self.function = _function
	self.bar_ratio_size = function.props.get("bar_ratio_size", 1.0)
	self.histogram_width = function.props.get("histogram_width", 1.0)
	self.bar_alignment = function.props.get("bar_alignment", Function.Alignment.CENTER)

func _draw() -> void:
	if self.function == null:
		return
	var box: Rect2 = get_box()
	var x_sampled_domain: Dictionary = { lb = box.position.x, ub = box.end.x }
	var y_sampled_domain: Dictionary = { lb = box.end.y, ub = box.position.y }
	sample(x_sampled_domain, y_sampled_domain)
	_draw_bars()

func sample(x_sampled_domain: Dictionary, y_sampled_domain: Dictionary) -> void:
	if self.function == null:
		return
	bars = []
	bars_rects = []
	for i in function.x.size():
		var top: Vector2 = Vector2(
			# ECUtilities._map_domain(i, x_domain, x_sampled_domain),
			ECUtilities._map_domain(function.x[i], x_domain, x_sampled_domain),
			ECUtilities._map_domain(function.y[i], y_domain, y_sampled_domain)
		)
		# var base: Vector2 = Vector2(top.x, ECUtilities._map_domain(0.0, y_domain, y_sampled_domain))
		var base: Vector2 = Vector2(top.x, ECUtilities._map_domain(y_domain.lb, y_domain, y_sampled_domain))
		
		var next_loc = ECUtilities._map_domain(function.x[i] + self.histogram_width, x_domain, x_sampled_domain)
		var width = (next_loc - top.x) * self.bar_ratio_size
		# var width = ECUtilities._map_domain(self.histogram_width * 0.5, x_domain, x_sampled_domain) # \
			# * self.bar_ratio_size
		var left_offset = ((next_loc - top.x) - width) * 0.5
		# print("i: %s x: %s x_domain: %s x_sampled_domain: %s" % [i, function.x[i], x_domain, x_sampled_domain])
		bars.push_back(top)
		bars.push_back(base)
		# print("x: %s y: %s top: %s base: %s" % [function.x[i], function.y[i], top, base])
		# print("x_domain: %s width: %s" % [x_domain, width])
		if self.bar_alignment == Function.Alignment.CENTER:
			# bars_rects.append(Rect2(Vector2(top.x - bar_ratio_size, top.y), Vector2(bar_ratio_size * 2, base.y - top.y)))
			bars_rects.append(Rect2(Vector2(top.x - (width * 0.5), top.y), Vector2(width, base.y - top.y)))
		elif self.bar_alignment == Function.Alignment.LEFT:
			# bars_rects.append(Rect2(Vector2(top.x, top.y), Vector2(bar_ratio_size * 2, base.y - top.y)))
			bars_rects.append(Rect2(Vector2(top.x + left_offset, top.y), Vector2(width, base.y - top.y)))

func _draw_bars() -> void:
	if self.function == null:
		return
	for bar in bars_rects:
		draw_rect(bar, function.get_color())

func _input(event: InputEvent) -> void:
	if self.function == null:
		return
	if event is InputEventMouse:
		for i in bars_rects.size():
			if bars_rects[i].grow(5).abs().has_point(get_relative_position(event.position)):
				var point: Point = Point.new(bars_rects[i].get_center(), { x = function.x[i], y = function.y[i]})
				if focused_bar_midpoint == point:
					return
				else:
					focused_bar_midpoint = point
					emit_signal("point_entered", point, function)
					return
		# Mouse is not in any point's box
		emit_signal("point_exited", focused_bar_midpoint, function)
		focused_bar_midpoint = null
