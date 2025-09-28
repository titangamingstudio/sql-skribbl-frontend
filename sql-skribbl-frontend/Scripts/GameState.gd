extends Node

var ws := WebSocketPeer.new()
var connected := false
var current_question_id: String = ""


func connect_to_server():
	var err = ws.connect_to_url("wss://sql-skribbl-backend.onrender.com/")
	if err != OK:
		push_error("WebSocket connect failed")
	else:
		connected = true

func send_message(data: Dictionary):
	if not connected: return
	var text = JSON.stringify(data)
	ws.send_text(text)

func poll():
	if not connected: return
	ws.poll()
	while ws.get_available_packet_count() > 0:
		var pkt = ws.get_packet().get_string_from_utf8()
		var msg = JSON.parse_string(pkt)
		if msg:
			get_tree().call_group("network_listeners", "_on_network_message", msg)
