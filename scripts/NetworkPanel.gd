extends ColorRect


func _ready():
	var ip_adress : String = "Unknown"

	if OS.has_feature("Windows"):
		if OS.has_environment("COMPUTERNAME"):
			ip_adress =  IP.resolve_hostname(str(OS.get_environment("COMPUTERNAME")),1)
	elif OS.has_feature("X11"):
		if OS.has_environment("HOSTNAME"):
			ip_adress =  IP.resolve_hostname(str(OS.get_environment("HOSTNAME")),1)
	elif OS.has_feature("OSX"):
		if OS.has_environment("HOSTNAME"):
			ip_adress =  IP.resolve_hostname(str(OS.get_environment("HOSTNAME")),1)
	
	$Content/IPLabel.text = "Private IP: " + ip_adress
	

func _input(event):
	if event is InputEventKey:
		if event.is_action_pressed("toggle_network_panel"):
			visible = !visible
			get_tree().paused = visible


func _on_HostButton_pressed():
	pass # Replace with function body.


func _on_JoinButton_pressed():
	if $Content/IPInput.text.is_valid_ip_address():
		Network.initialise_client($Content/IPInput.text)
	else:
		$Content/InvalidIP.show()
