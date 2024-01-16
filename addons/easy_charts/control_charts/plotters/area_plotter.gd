extends LinePlotter
class_name AreaPlotter

func _init(function: Function).(function) -> void:
	pass

func _draw_areas() -> void:
	var box: Rect2 = get_box()
	var fp_augmented: PoolVector2Array = []
	match function.get_interpolation():
		Function.Interpolation.LINEAR:
			fp_augmented = points_positions
		Function.Interpolation.STAIR:
			fp_augmented = _get_stair_points()
		Function.Interpolation.SPLINE:
			fp_augmented = _get_spline_points()
	
	fp_augmented.insert(0, Vector2(fp_augmented[0].x, box.end.y))
	fp_augmented.push_back(Vector2(fp_augmented[-1].x, box.end.y))
	
	var colors: PoolColorArray = []
	var gradient = function.props.get("gradient", null)
	if gradient:
		# var base_color: Color = function.get_color()
		for point in fp_augmented:
			var start = box.position.y
			var end = box.end.y
			var total_dist = end - start
			var loc = point.y - start
			# assert(total_dist >= 0)
			# assert(loc >= 0)
			# assert(end >= loc)
			# assert(start <= loc)
			var lerp_val = clamp(loc / float(total_dist), 0.0, 1.0)
			# base_color.a = range_lerp(point.y, box.end.y, box.position.y, 0.0, 1.0)
			var base_color = gradient.interpolate(lerp_val)
			colors.push_back(base_color)
	else:
		var base_color: Color = function.get_color()
		for point in fp_augmented:
			base_color.a = range_lerp(point.y, box.end.y, box.position.y, 0.0, 1.0)
			colors.push_back(base_color)
	draw_polygon(fp_augmented, colors)

func _draw() -> void:
	if !self._should_draw:
		return
	_draw_areas()
