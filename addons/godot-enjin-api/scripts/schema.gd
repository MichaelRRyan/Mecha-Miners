extends Node
class_name EnjinAPISchema


#-------------------------------------------------------------------------------
onready var login_query = GraphQL.query("Login", {
		"email": "String!",
		"password": "String!",
	}, GQLQuery.new("EnjinOauth").set_args({ 
		"email": "$email",
		"password": "$password",
	}).set_props([
		"id",
		"name",
		"accessTokens",
	]))


#-------------------------------------------------------------------------------
onready var get_user_info = GraphQL.query("GetUserInfo", {
		"id": "Int!",
	}, GQLQuery.new("EnjinUser").set_args({ 
		"id": "$id",
	}).set_props([
		"name",
		"id",
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
		"userId": "$userId",
		"appId": "$appId",
		"ethAddress": "$ethAddress",
	}).set_props([
		"id",
		"createdAt",
		"linkingCode",
		"linkingCodeQr",
		GQLQuery.new("app").set_props([
			"id",
			"name"
		]),
		GQLQuery.new("wallet").set_props([
			"ethAddress",
		]),
		GQLQuery.new("user").set_props([
			"id",
		]),
	]))


#-------------------------------------------------------------------------------
onready var mint_tokens = GraphQL.mutation("MintToken", {
		"identityId": "Int!", 
		"appId": "Int!", 
		"tokenId": "String!",
		"recipientAddress": "String!",
		"value": "Int!"
	}, GQLQuery.new("CreateEnjinRequest").set_args({ 
		"identityId": "$identityId",
		"appId": "$appId",
		"type": "MINT",
		"mint_token_data": { 
			"token_id": "$tokenId",
			"recipient_address_array": "[$recipientAddress]",
			"value_array": "[$value]"
		}
	}).set_props([
		"id",
		"encodedData",
		"error",
	]))


#-------------------------------------------------------------------------------
onready var send_tokens = GraphQL.mutation("SendToken", {
		"identityId": "Int!", 
		"appId": "Int!", 
		"tokenId": "String!",
		"recipientAddress": "String!",
		"value": "Int!"
	}, GQLQuery.new("CreateEnjinRequest").set_args({ 
		"identityId": "$identityId",
		"appId": "$appId",
		"type": "SEND",
		"send_token_data": { 
			"token_id": "$tokenId",
			"recipient_address": "$recipientAddress",
			"value": "$value"
		}
	}).set_props([
		"id",
		"encodedData",
		"error",
	]))
	

#-------------------------------------------------------------------------------
onready var retrieve_app_access_token_query = GraphQL.query("RetrieveAppAccessToken", {
		"appId": "Int!",
		"appSecret": "String!",
	}, GQLQuery.new("AuthApp").set_args({ 
		"id": "$appId",
		"secret": "$appSecret",
	}).set_props([
		"accessToken",
		"expiresIn",
	]))


#-------------------------------------------------------------------------------
onready var queries = [
	login_query,
	get_user_info,
	create_identity,
	retrieve_app_access_token_query,
	mint_tokens,
	send_tokens,
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
