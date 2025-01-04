extends VBoxContainer
class_name FunctionLegend

onready var f_label_scn: PackedScene = preload("res://addons/easy_charts/utilities/containers/legend/function_label.tscn")

var chart_properties: ChartProperties

const NUM_LABELS = 11

func _ready() -> void:
	for i in range(NUM_LABELS):
		var f_label: FunctionLabel = f_label_scn.instance()
		add_child(f_label)

func clear() -> void:
	# for label in get_children():
	# 	label.queue_free()
	pass

func add_function(function: Function, idx: int) -> void:
	# var f_label: FunctionLabel = f_label_scn.instance()
	# add_child(f_label)
	var funcs = self.get_children()
	funcs[idx].init_label(function)

# func add_label(type: int, color: Color, marker: int, name: String) -> void:
# 	var f_label: FunctionLabel = f_label_scn.instance()
# 	add_child(f_label)
# 	f_label.init_clabel(type, color, marker, name)
