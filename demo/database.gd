extends Node

const SQLite = preload("res://addons/godot-sqlite/bin/gdsqlite.gdns")
var db

var db_name := "res://data/test"

var table_name := "posts"

signal output_received(text)

func _ready():
	if OS.get_name() == "Android" or OS.get_name() == "iOS":
		copy_data_to_user()
		db_name = "user://data/test"

	# Enable/disable examples here:
	example_of_basic_database_querying()

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

# Basic example that goes over all the basic features available in the addon, such
# as creating and dropping tables, inserting and deleting rows and doing more elementary
# PRAGMA queries.
func example_of_basic_database_querying():

	db = SQLite.new()
	db.path = db_name
	db.verbose_mode = true
	# Open the database using the db_name found in the path variable
	db.open_db()
	#db.drop_table(table_name)

	db.query("CREATE VIRTUAL TABLE posts USING FTS5(title, body);")

	var row_array := [
		{"title":'Learn SQlite FTS5', "body":'This tutorial teaches you how to perform full-text search in SQLite using FTS5'},
		{"title":'Advanced SQlite Full-text Search', "body":'Show you some advanced techniques in SQLite full-text searching'},
		{"title":'SQLite Tutorial', "body":'Help you learn SQLite quickly and effectively'},
	]

	db.insert_rows(table_name, row_array)

	# Close the current database
	db.close_db()
