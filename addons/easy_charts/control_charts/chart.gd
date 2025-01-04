extends PanelContainer
class_name Chart, "res://addons/easy_charts/utilities/icons/linechart.svg"

onready var _canvas: Canvas = $Canvas
onready var plot_box: PlotBox = $"%PlotBox"
onready var grid_box: GridBox = $"%GridBox"
onready var functions_box: Control = $"%FunctionsBox"
onready var function_legend: FunctionLegend = $"%FunctionLegend"

const MAX_NUM_FUNCTIONS = 11
var functions: Array = []
var x: Array = []
var y: Array = []
# var _function_nodes: Array = []

var function_plotters = []

var x_labels: PoolStringArray = []
var y_labels: PoolStringArray = []

var _x_domain = null
var _y_domain = null

var _should_plot = false

var _plotbox_margins = Vector2(0.0, 0.0)

var chart_properties: ChartProperties = ChartProperties.new()

###########

func _ready():
	for i in range(self.MAX_NUM_FUNCTIONS):
		# Jank: We are only supporting bar plotter at the moment
		var function_plotter = BarPlotter.new()
		function_plotter.connect("point_entered", self.plot_box, "_on_point_entered")
		function_plotter.connect("point_exited", self.plot_box, "_on_point_exited")
		self.functions_box.add_child(function_plotter)
		self.function_plotters.append(function_plotter)


func plot(functions: Array, properties: ChartProperties = ChartProperties.new(), x_domain=null, y_domain=null) -> void:
	self.functions = functions
	self.chart_properties = properties
	self._x_domain = x_domain
	self._y_domain = y_domain
	
	theme.set("default_font", self.chart_properties.font)
	_canvas.prepare_canvas(self.chart_properties)
	plot_box.chart_properties = self.chart_properties
	function_legend.chart_properties = self.chart_properties
	load_functions(functions)

	# Some jank that I made to allow the chart to exist without being drawn on
	# self._should_plot = false
	# self.hide()
	# self.update()
	# self.grid_box.hide()
	# self.grid_box.update()
	# yield(get_tree(), "idle_frame")
	self._should_plot = true
	self.show()
	self.update()
	self.grid_box.show()
	self.grid_box.update()

func clear():
	self._should_plot = false
	# for fp in self.functions_box.get_children():
	# 	fp.queue_free()
	self.update()

# func get_function_plotter(function: Function) -> FunctionPlotter:
# 	var plotter: FunctionPlotter
# 	match function.get_type():
# 		Function.Type.SCATTER:
# 			plotter = ScatterPlotter.new(function)
# 		Function.Type.LINE:
# 			plotter = LinePlotter.new(function)
# 		Function.Type.AREA:
# 			plotter = AreaPlotter.new(function)
# 		Function.Type.PIE:
# 			plotter = PiePlotter.new(function)
# 		Function.Type.BAR:
# 			plotter = BarPlotter.new(function)
# 	return plotter

func load_functions(functions: Array) -> void:
	self.x = []
	self.y = []
	
	function_legend.clear()
	
	# for function in functions:
	for j in range(len(functions)):
		var function = functions[j]
		# Load x and y values
		self.x.append(function.x)
		self.y.append(function.y)
		
		# Load Labels
		if self.x_labels.empty():
			if ECUtilities._contains_string(function.x):
				self.x_labels = function.x
		
		# Create FunctionPlotter
		# var function_plotter: FunctionPlotter = get_function_plotter(function)
		# function_plotter.connect("point_entered", plot_box, "_on_point_entered")
		# function_plotter.connect("point_exited", plot_box, "_on_point_exited")
		# functions_box.add_child(function_plotter)
		# self.function_plotters.append(function_plotter)
		self.function_plotters[j].set_function(function)
		
		# # Create legend
		# match function.get_type():
		# 	Function.Type.PIE:
		# 		for i in function.x.size():
		# 			var interp_color: Color = function.get_gradient().interpolate(float(i) / float(function.x.size()))
		# 			function_legend.add_label(function.get_type(), interp_color, Function.Marker.NONE, function.y[i])
		# 	_:
		# 		function_legend.add_function(function)
		function_legend.add_function(function, j)

func _draw() -> void:
	if not self._should_plot:
		return
	# GridBox
	var x_domain = self._x_domain
	var y_domain = self._y_domain
	var local_x = self.x.duplicate(true)
	var local_y = self.y.duplicate(true)
	if self.chart_properties.force_x_domain_origin:
		for f_x in local_x:
			f_x.append(0.0)
	if self.chart_properties.force_y_domain_origin:
		for f_y in local_y:
			f_y.append(0.0)
	if x_domain == null:
		x_domain = calculate_domain(
			local_x,
			self.chart_properties.x_domain_round,
			self.chart_properties.x_domain_buffer,
			self.chart_properties.force_x_int_ticks,
			self.chart_properties.x_scale
		)
	if y_domain == null:
		y_domain = calculate_domain(
			local_y,
			self.chart_properties.y_domain_round,
			self.chart_properties.y_domain_buffer,
			self.chart_properties.force_y_int_ticks,
			self.chart_properties.y_scale
		)
	
	var plotbox_margins: Vector2 = calculate_plotbox_margins(x_domain, y_domain)
	
	# Update values for the PlotBox in order to propagate them to the children
	plot_box.box_margins = plotbox_margins
	
	# Update GridBox
	update_gridbox(x_domain, y_domain, self.x_labels, self.y_labels)
	
	# Update each FunctionPlotter in FunctionsBox
	for function_plotter in functions_box.get_children():
		function_plotter.update_values(x_domain, y_domain)

func calculate_domain(
		values: Array,
		should_round=false,
		additional_buffer=0.0,
		force_int_ticks=false,
		scale=1.0
	) -> Dictionary:
	for value_array in values:
		if ECUtilities._contains_string(value_array):
			return { lb = 0.0, ub = (value_array.size() - 1), has_decimals = false }
	var min_max: Dictionary = ECUtilities._find_min_max(
		values,
		scale,
		force_int_ticks
	)
	if should_round:
		return {
			lb = ECUtilities._round_min(min_max.min),
			ub = ECUtilities._round_max(min_max.max) + additional_buffer,
			has_decimals = ECUtilities._has_decimals(values) 
		}
	else:
		return {
			lb = min_max.min,
			ub = min_max.max + additional_buffer,
			has_decimals = ECUtilities._has_decimals(values)
		}

func update_gridbox(x_domain: Dictionary, y_domain: Dictionary, x_labels: PoolStringArray, y_labels: PoolStringArray) -> void:
	grid_box.set_domains(x_domain, y_domain)
	grid_box.set_labels(x_labels, y_labels)
	grid_box.update()

func get_plotbox_progress_bounds():
	# return self.grid_box.box
	var plotbox = self.plot_box.get_plot_box()
	var offset = self.plot_box.get_global_position() - self.get_global_position()
	print("self pos: %s plotbox pos: %s plotbox: %s" % [self.get_global_position(), self.plot_box.get_global_position(), plotbox])
	plotbox.position += offset
	return plotbox
	# return self._plotbox_margins

func calculate_plotbox_margins(x_domain: Dictionary, y_domain: Dictionary) -> Vector2:
	var plotbox_margins: Vector2 = Vector2(
		chart_properties.x_tick_size if chart_properties.show_y_tick_labels else 0.0,
		chart_properties.y_tick_size if chart_properties.show_x_tick_labels else 0.0
	)
	
	if chart_properties.show_y_tick_labels or chart_properties.show_x_tick_labels:
		var x_ticklabel_size: Vector2
		var y_ticklabel_size: Vector2
		
		var y_max_formatted: String = ECUtilities._format_value(y_domain.ub, y_domain.has_decimals)
		if y_domain.lb < 0: # negative number
			var y_min_formatted: String = ECUtilities._format_value(y_domain.lb, y_domain.has_decimals)
			if y_min_formatted.length() >= y_max_formatted.length():
				 y_ticklabel_size = chart_properties.font.get_string_size(y_min_formatted)
			else:
				y_ticklabel_size = chart_properties.font.get_string_size(y_max_formatted)
		else:
			y_ticklabel_size = chart_properties.font.get_string_size(y_max_formatted)

		if chart_properties.show_y_tick_labels:
			plotbox_margins.x += y_ticklabel_size.x + chart_properties.x_ticklabel_space
		if chart_properties.show_x_tick_labels:
			plotbox_margins.y += chart_properties.font.size + chart_properties.y_ticklabel_space

	self._plotbox_margins = plotbox_margins
	return plotbox_margins
