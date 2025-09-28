extends Node

var ws := WebSocketPeer.new()
var connected := false
var current_question_id: String = ""   # start as empty string

@onready var status_label := $StatusLabel
@onready var round_label := $RoundLabel
@onready var question_label := $QuestionBox/QuestionLabel
@onready var sql_input := $SqlInput
@onready var run_button := $RunButton
@onready var result_label := $ResultBox/ResultLabel

# Timer state
var round_time: int = 0     # total seconds per round (set by server)
var time_left: float = 0.0  # countdown
var round_active: bool = false

func _ready():
	var url : String
	if OS.has_feature("web"):  
		url = "wss://sql-skribbl-backend.onrender.com"  # hosted backend
	else:
		url = "ws://127.0.0.1:3000"   # local dev server
	status_label.text = "Connecting to: " + url

	var err = ws.connect_to_url(url)
	if err != OK:
		status_label.text = "Unable to connect!"
	set_process(true)

	# Connect RunButton pressed
	run_button.pressed.connect(_on_run_button_pressed)

func _process(delta):
	ws.poll()

	var status = ws.get_ready_state()
	if status == WebSocketPeer.STATE_OPEN and not connected:
		connected = true
		status_label.text = "Connected to server!"

		# 🔹 Send join request once connected
		var join_msg = {
			"type": "join_single",
			"username": "Rohit",           # TODO: replace with Global.username
			"difficulty": "beginner"       # TODO: replace with Global.difficulty
		}
		ws.send_text(JSON.stringify(join_msg))

	elif status == WebSocketPeer.STATE_CLOSED:
		status_label.text = "Connection closed"

	# 🔹 Countdown handling
	if round_active:
		time_left -= delta
		if time_left > 0:
			round_label.text = "⏱ " + str(int(time_left)) + "s left"
		else:
			round_label.text = "⏱ Time up!"
			round_active = false
			run_button.disabled = true

	while ws.get_available_packet_count() > 0:
		var pkt = ws.get_packet().get_string_from_utf8()
		_on_message(pkt)

func _on_message(msg: String) -> void:
	var json = JSON.new()
	var err = json.parse(msg)
	if err == OK:
		var obj = json.data

		if obj.has("type") and obj.type == "question":
			# backend sends: { type:"question", question_id, prompt, round_time }
			current_question_id = obj.question_id
			question_label.text = str(obj.prompt)
			result_label.text = ""

			# 🔹 Start new round timer using server value
			if obj.has("round_time"):
				round_time = int(obj.round_time)
			else:
				round_time = 30  # fallback
			time_left = float(round_time)
			round_active = true
			run_button.disabled = false

		elif obj.has("type") and obj.type == "validation_result":
			if obj.verdict == "ok":
				var rows_text = ""
				for row in obj.rows:
					rows_text += str(row) + "\n"
				result_label.text = "✅ Correct!\n" + rows_text
				if obj.has("first_correct") and obj.first_correct:
					result_label.text += "\n🥇 First correct!"
			else:
				result_label.text = "❌ Wrong\nExpected:\n" + str(obj.expected)

		elif obj.has("type") and obj.type == "error":
			result_label.text = "⚠️ Error: " + str(obj.message)
	else:
		print("JSON parse error:", err)

func _on_run_button_pressed() -> void:
	if not connected or current_question_id == "":
		return
	var payload = {
		"type": "submit_sql",
		"sql": sql_input.text,
		"question_id": current_question_id
	}
	ws.send_text(JSON.stringify(payload))
