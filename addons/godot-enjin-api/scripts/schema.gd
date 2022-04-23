extends Node
class_name EnjinAPISchema


#-------------------------------------------------------------------------------
onready var login_query = GraphQL.query("Login", {
		"email": "String!",
		"password": "String!",
	}, GQLQuery.new("EnjinOauth").set_args({ 
		"email": "email",
		"password": "password",
	}).set_props([
		"id",
		"name",
		"accessTokens",
	]))


#-------------------------------------------------------------------------------
onready var get_user_info = GraphQL.query("GetUserInfo", {
		"id": "Int!",
	}, GQLQuery.new("EnjinUser").set_args({ 
		"id": "id",
	}).set_props([
		"name",
		"createdAt",
		"updatedAt",
		"isPlayer",
		GQLQuery.new("identities").set_props([
			"id",
			GQLQuery.new("app").set_props([
				"id",
				"name"
			]),
			GQLQuery.new("wallet").set_props([
				"ethAddress",
			]),
		]),
		GQLQuery.new("items").set_props([
			"id",
			"name",
		]),
	]))


#-------------------------------------------------------------------------------
onready var create_identity = GraphQL.mutation("CreateIdentity", {
		"userId": "Int!",
		"appId": "Int!",
		"ethAddress": "String!",
	}, GQLQuery.new("CreateEnjinIdentity").set_args({ 
		"userId": "userId",
		"appId": "appId",
		"ethAddress": "ethAddress",
	}).set_props([
		"id",
		"createdAt",
		GQLQuery.new("wallet").set_props([
			"ethAddress",
		]),
	]))


#-------------------------------------------------------------------------------
onready var get_app_secret_query = GraphQL.query("GetAppSecret", {
		"id": "Int!",
	}, GQLQuery.new("EnjinApps").set_args({ 
		"id": "id",
	}).set_props([
		"secret",
	]))
	

#-------------------------------------------------------------------------------
onready var retrieve_app_access_token_query = GraphQL.query("RetrieveAppAccessToken", {
		"appId": "Int!",
		"appSecret": "String!",
	}, GQLQuery.new("AuthApp").set_args({ 
		"appId": "id",
		"appSecret": "secret",
	}).set_props([
		"accessToken",
		"expiresIn",
	]))


#-------------------------------------------------------------------------------
onready var queries = [
	login_query,
	get_user_info,
	create_identity,
	get_app_secret_query,
	retrieve_app_access_token_query,
]


#-------------------------------------------------------------------------------
func set_bearer(bearer : String) -> void:
	for query in queries:
		query.set_bearer(bearer)


#-------------------------------------------------------------------------------
func remove_bearer() -> void:
	for query in queries:
		query.remove_bearer()
	
	
#-------------------------------------------------------------------------------
func _ready() -> void:
	for query in queries:
		add_child(query)


#-------------------------------------------------------------------------------
