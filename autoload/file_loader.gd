extends Node


## [param encryption_pass] should be from [code]"somestring".sha256_buffer()[/code]
func get_encrypted(file_path : String, encryption_pass : PackedByteArray) -> Variant:
	var file = FileAccess.open_encrypted(file_path, FileAccess.READ, encryption_pass)
	if not file:
		return {}
	var entries = JSON.parse_string(file.get_as_text())
	file.close()
	return entries

## [param encryption_pass] should be from [code]"somestring".sha256_buffer()[/code]
func save_encrypted(file_path : String, encryption_pass : PackedByteArray, data : Variant):
	var file = FileAccess.open_encrypted(file_path, FileAccess.WRITE, encryption_pass)
	file.store_string(JSON.stringify(data, "\t"))
	file.close()
