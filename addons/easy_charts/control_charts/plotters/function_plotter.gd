extends Control
class_name FunctionPlotter

var function: Function
var x_domain: Dictionary
var y_domain: Dictionary

var _should_draw = true

# func _init(function: Function) -> void:
# 	self.function = function

func set_function(function: Function) -> void:
	self.function = function

# func _ready() -> void:
# 	set_process_input(get_chart_properties().interactive)

func clear():
	self._should_draw = false
	self.update()
	# yield(get_tree(), "idle_frame")
	self._should_draw = true

func update_values(x_domain: Dictionary, y_domain: Dictionary) -> void:
	self.x_domain = x_domain
	self.y_domain = y_domain
	update()

func _draw() -> void:
	pass

func get_box() -> Rect2:
	return get_parent().get_parent().get_plot_box()

func get_chart_properties() -> ChartProperties:
	return get_parent().get_parent().chart_properties

func get_relative_position(position: Vector2) -> Vector2:
	return position - rect_global_position
