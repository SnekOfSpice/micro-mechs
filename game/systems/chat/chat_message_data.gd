extends Node
class_name ChatMessageData

const SOURCE_SYSTEM := 0
enum MessageType {
	PLAYER,
	SYSTEM,
}
var message_type := MessageType.PLAYER
var content: String
var source: int
