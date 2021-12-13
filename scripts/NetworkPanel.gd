extends ColorRect


# -----------------------------------------------------------------------------
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
	

# -----------------------------------------------------------------------------
func _input(event):
	if event is InputEventKey:
		if event.is_action_pressed("toggle_network_panel"):
			visible = !visible
			get_tree().paused = visible
		
		if event.is_action_pressed("exit"):
			get_tree().quit()


# -----------------------------------------------------------------------------
func _on_HostButton_pressed():
	# If we're already hosting, do nothing.
	if Network.state == Network.State.Hosting: return
	
	# If we're not offline, close the connection first.
	if Network.state != Network.State.Offline:
		Network.close_connection()
	
	Network.start_server()
	$Content/HostingStatus.text = "Status: Hosting on private IP."


# -----------------------------------------------------------------------------
func _on_JoinButton_pressed():
	if Network.state == Network.State.Connecting: return
	
	if Network.state != Network.State.Offline:
		Network.close_server()
		
	if $Content/IPInput.text.is_valid_ip_address():
		Network.connect_to_server($Content/IPInput.text)
	else:
		$Content/InvalidIP.show()


# -----------------------------------------------------------------------------
