extends Node

const SQLite = preload("res://addons/godot-sqlite/bin/gdsqlite.gdns")
var db

var db_name := "res://data/test"
var table_name := "posts"

signal output_received(text)

func _ready():
	if OS.get_name() in ["Android", "iOS", "HTML5"]:
		copy_data_to_user()
		db_name = "user://data/test"

	# Enable/disable examples here:
	example_of_fts5_usage()

func cprint(text : String) -> void:
	print(text)
	emit_signal("output_received", text)

func copy_data_to_user() -> void:
	var data_path := "res://data"
	var copy_path := "user://data"

	var dir = Directory.new()
	dir.make_dir(copy_path)
	if dir.open(data_path) == OK:
		dir.list_dir_begin();
		var file_name = dir.get_next()
		while (file_name != ""):
			if dir.current_is_dir():
				pass
			else:
				cprint("Copying " + file_name + " to /user-folder")
				dir.copy(data_path + "/" + file_name, copy_path + "/" + file_name)
			file_name = dir.get_next()
	else:
		cprint("An error occurred when trying to access the path.")

# Basic example that showcases seaching functionalities of FTS5...
func example_of_fts5_usage():

	db = SQLite.new()
	if not db.has_feature("enable_fts5"):
		cprint("No support for FTS5 available in libraries (re-build libraries with argument `enable_fts5=true`)")
		return

	db.path = db_name
	db.verbose_mode = true
	# Open the database using the db_name found in the path variable
	db.open_db()
	db.drop_table(table_name)

	db.query("CREATE VIRTUAL TABLE " + table_name + " USING FTS5(title, body);")

	var row_array := [
		{"title":'Learn SQlite FTS5', "body":'This tutorial teaches you how to perform full-text search in SQLite using FTS5'},
		{"title":'Advanced SQlite Full-text Search', "body":'Show you some advanced techniques in SQLite full-text searching'},
		{"title":'SQLite Tutorial', "body":'Help you learn SQLite quickly and effectively'},
	]

	db.insert_rows(table_name, row_array)

	db.query("SELECT * FROM " + table_name + " WHERE posts MATCH 'fts5';")
	cprint("result: {0}".format([String(db.query_result)]))

	db.query("SELECT * FROM " + table_name + " WHERE posts MATCH 'learn SQLite';")
	cprint("result: {0}".format([String(db.query_result)]))

	# Close the current database
	db.close_db()
