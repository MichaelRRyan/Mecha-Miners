extends Node

signal login_response(successful, errors)
signal get_user_info_response(info, errors)
signal create_identity_response(info, errors)

const APP_ID : int = 6145

enum RequestType {
	LOGIN,
	GET_USER_INFO,
	CREATE_IDENTITY,
}

var print_response = true

var _SchemaScene = preload("res://addons/godot-enjin-api/scenes/schema.tscn")
var _schema : EnjinAPISchema = null
var _queued_queries = []

var _root_ready = false
var _initialised = false

var _bearer : String = ""
var _user_id : int = -1


#-------------------------------------------------------------------------------
# Public Methods
#-------------------------------------------------------------------------------
func connect_to_enjin() -> void:
	if not _root_ready:
		yield(get_tree().root, "ready")
		
	GraphQL.set_endpoint(true, "kovan.cloud.enjin.io/graphql", 0, "")
	_setup()


#-------------------------------------------------------------------------------
func login(username : String, password : String):
	_execute("login_query", {
		"email": username,
		"password": password,
	})


#-------------------------------------------------------------------------------
func logout():
	_schema.remove_bearer()
	_bearer = ""
	_user_id = -1
	

#-------------------------------------------------------------------------------
func get_current_user_id() -> int:
	return _user_id


#-------------------------------------------------------------------------------
# Gets the info for the logged in user.
func get_current_user_info() -> void:
	if _user_id != -1:
		get_user_info(_user_id)
	else:
		print("Error: No user signed in while trying to access current user data.")


#-------------------------------------------------------------------------------
func get_user_info(id : int) -> void:
	_execute("get_user_info", {
		"id": id,
	})


#-------------------------------------------------------------------------------
func create_identity(user_id : int, eth_address : String) -> void:
	_execute("create_identity", {
		"appId": APP_ID,
		"userId": user_id,
		"ethAddress": eth_address,
	})


#-------------------------------------------------------------------------------
# Response methods
#-------------------------------------------------------------------------------
func _request_response(result, request_type):
	if print_response:
		print(JSON.print(result, "\t"))
	
	match (request_type):
		RequestType.LOGIN:
			_login_response(result)
		RequestType.GET_USER_INFO:
			_get_user_data_response(result)
		RequestType.CREATE_IDENTITY:
			_create_identity_response(result)
			

#-------------------------------------------------------------------------------
func _login_response(result):
	if result.has("errors"):
		emit_signal("login_response", false, result.errors)
		
	else:
		var auth = result.data.EnjinOauth
		if auth != null:
			_user_id = auth.id
			_bearer = auth.accessTokens[0].accessToken
			_schema.set_bearer(_bearer)
			
			emit_signal("login_response", true, null)
	

#-------------------------------------------------------------------------------
func _get_user_data_response(result):
	if result.has("errors"):
		emit_signal("get_user_info_response", null, result.errors)
		
	else:
		var info = result.data.EnjinUser
		if info != null:
			emit_signal("get_user_info_response", info, null)
		
		
#-------------------------------------------------------------------------------
func _create_identity_response(result):
	if result.has("errors"):
		emit_signal("create_identity_response", null, result.errors)
		
	else:
		var info = result.data.CreateEnjinIdentity
		if info != null:
			emit_signal("create_identity_response", info, null)


#-------------------------------------------------------------------------------
func _get_app_secret_response(result):
	var secret = result.data.EnjinApps[0].secret
	if secret != null:
		_schema.retrieve_app_access_token_query.set_bearer(_bearer)
		_schema.retrieve_app_access_token_query.run({
			"appId": APP_ID,
			"appSecret": secret,
		})
		
		_schema.create_player_mutation.set_bearer(_bearer)
		_schema.create_player_mutation.run({ "playerId": "Michael" })


#-------------------------------------------------------------------------------
func _retrieve_app_access_token_response(result):
	#var secret = result.data.EnjinApps[0].secret
	print(JSON.print(result, "\t"))


#-------------------------------------------------------------------------------
func _create_player_response(result):
	#var secret = result.data.EnjinApps[0].secret
	print(JSON.print(result, "\t"))


#-------------------------------------------------------------------------------
# Setup methods
#-------------------------------------------------------------------------------
func _setup():
	if not _initialised:
		var root = get_tree().root
		_schema = _SchemaScene.instance()
		root.add_child(_schema)
		
		# Connects the queries and mutations' signals to methods.
		_schema.login_query.connect("graphql_response", self, "_request_response", [ RequestType.LOGIN ])
		_schema.get_user_info.connect("graphql_response", self, "_request_response", [ RequestType.GET_USER_INFO ])
		_schema.create_identity.connect("graphql_response", self, "_request_response", [ RequestType.CREATE_IDENTITY ])
		
		_schema.get_app_secret_query.connect("graphql_response", self, "_get_app_secret_response")
		_schema.retrieve_app_access_token_query.connect("graphql_response", self, "_retrieve_app_access_token_response")
		
		_initialised = true
		
		# Runs any queued queries.
		if _queued_queries.size():
			for query in _queued_queries:
				_schema.get(query.query_name).run(query.args)


#-------------------------------------------------------------------------------
# Runs the query if initialised, queues it otherwise.
func _execute(query_name : String, args : Dictionary) -> void:
	if _initialised:
		_schema.get(query_name).run(args)
		
	else:
		_queued_queries.append({
			query_name = query_name,
			args = args,
		})


#-------------------------------------------------------------------------------
func _ready():
	get_tree().root.connect("ready", self, "_on_tree_ready")
	connect_to_enjin()
	
	
#-------------------------------------------------------------------------------
func _on_tree_ready():
	_root_ready = true
	
	
#-------------------------------------------------------------------------------
