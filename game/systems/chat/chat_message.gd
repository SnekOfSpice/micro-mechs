extends RichTextLabel
class_name ChatMessage

var data: ChatMessageData


func _enter_tree() -> void:
	bbcode_enabled = true
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fit_content = true
	text = data.content
	if data.message_type == ChatMessageData.MessageType.SYSTEM:
		var system_color := Color(0.991, 0.782, 0.378, 1.0)
		text = "[i][color=%s]SYSTEM: %s[/color][/i]" % [system_color.to_html(), text]
