extends Control

@onready var bar = $Center/VBox/Bar
@onready var text = $Center/VBox/Label
var next_scene: String
var progress: Array[float]
var loading_status: int
	
func _process(_delta: float) -> void:
	loading_status = ResourceLoader.load_threaded_get_status(next_scene, progress)
	match loading_status:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			bar.value = progress[0] * 100
			text.text = str(progress[0] * 100) + "%"
		ResourceLoader.THREAD_LOAD_LOADED:
			bar.value = progress[0] * 100
			text.text = str(progress[0] * 100) + "%"
			await get_tree().create_timer(1).timeout
			get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get(next_scene))
			self.free()
		ResourceLoader.THREAD_LOAD_FAILED:
			print("Error")
			# Return to Menu?
			
func _ready() -> void:
	bar.value = 0
	text.text = str(0) + "%"
	set_process(false)
	await get_tree().create_timer(1).timeout
	set_process(true)
	
func change_scene(next: String) -> void:
	next_scene = next
	var res = ResourceLoader.load_threaded_request(next_scene)
