extends Control

const ANIM_STEP_SIZE = 0.003
const FINISH_LOAD_WAIT_TIME = 2

@onready var bar = $Center/VBox/Bar
@onready var text = $Center/VBox/Label

var next_scene: String
var progress_arr: Array[float]
var progress: float
var progress_anim_ease_step: float
var loading_status: int
var done_wait: float
var done: bool
	
func _process(_delta: float) -> void:
	loading_status = ResourceLoader.load_threaded_get_status(next_scene, progress_arr)
	if progress_arr[0] != progress: # On load update, reset ease state
		progress = progress_arr[0]
		progress_anim_ease_step = 0
	progress_anim_ease_step += ANIM_STEP_SIZE
	bar.value += cubicEase(progress_anim_ease_step) * (progress * 100 - bar.value) # Easing State times Bar Progress Delta
	text.text = str(roundf(bar.value*100)/100) + "%"
	if done_wait > FINISH_LOAD_WAIT_TIME:
		get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get(next_scene))
		self.free()
	if done:
		done_wait += _delta
		return
	match loading_status:
		ResourceLoader.THREAD_LOAD_LOADED:
			done = true
			done_wait = 0
		ResourceLoader.THREAD_LOAD_FAILED:
			print("Error")
			# Return to Menu?
			
# This is just so that the bar doesnt start at infinity cuz the scene loads so quick
func _ready() -> void:
	bar.value = 0
	text.text = str(0) + "%"
	set_process(false)
	await get_tree().create_timer(1).timeout
	set_process(true)
	
func change_scene(next: String) -> void:
	next_scene = next
	done = false
	if not ResourceLoader.has_cached(next_scene):
		ResourceLoader.load_threaded_request(next_scene)
	
func cubicEase(x: float) -> float:
	return 4 * x * x * x if x < 0.5 else 1 - pow(-2 * x + 2, 3) / 2;
