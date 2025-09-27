extends Node

var ws := WebSocketPeer.new()
var connected := false

@onready var status_label := $StatusLabel
@onready var question_label := $QuestionBox/QuestionLabel
@onready var sql_input := $SqlInput
@onready var run_button := $RunButton
@onready var result_label := $ResultBox/ResultLabel

func _ready():
	var url : String
	if OS.has_feature("web"):  
		# Running in browser (HTML5 export)
		url = "wss://sql-skribbl-backend.onrender.com/"
	else:
		# Running inside Godot editor/native
		url = "ws://127.0.0.1:3000"   # local dev server
	status_label.text = "Connecting to: " + url

	var err = ws.connect_to_url(url)
	if err != OK:
		status_label.text = "Unable to connect!"
	set_process(true)

	# Connect RunButton pressed
	run_button.pressed.connect(_on_run_button_pressed)

func _process(_delta):
	ws.poll()

	var status = ws.get_ready_state()
	if status == WebSocketPeer.STATE_OPEN and not connected:
		connected = true
		status_label.text = "Connected to server!"
	elif status == WebSocketPeer.STATE_CLOSED:
		status_label.text = "Connection closed"

	while ws.get_available_packet_count() > 0:
		var pkt = ws.get_packet().get_string_from_utf8()
		_on_message(pkt)

func _on_message(msg: String) -> void:
	var json = JSON.new()
	var err = json.parse(msg)
	if err == OK:
		var obj = json.data
		# Show question text
		if obj.has("type") and obj.type == "question":
			question_label.text = str(obj.text)
		# Show validation result
		elif obj.has("type") and obj.type == "validation_result":
			if obj.verdict == "ok":
				var rows_text = ""
				for row in obj.rows:
					rows_text += str(row) + "\n"
				result_label.text = "✅ Correct!\n" + rows_text
			else:
				result_label.text = "❌ Error: " + str(obj.message)
	else:
		print("JSON parse error:", err)

func _on_run_button_pressed() -> void:
	if not connected:
		return
	var payload = {
		"type": "submit_sql",
		"sql": sql_input.text
	}
	var txt = JSON.stringify(payload)
	ws.send_text(txt)
