extends Tabs

const SIGN_UP_LINK = "https://kovan.cloud.enjin.io/signup"
const ANDROID_APP_LINK = "https://play.google.com/store/apps/details?id=com.enjin.mobile.wallet&referrer=utm_source%3Dorganic_software_wallet%26utm_medium%3DOrganic%26utm_term%3Dsoftware_wallet_LP%26utm_content%3DDownload_Icon"
const IOS_APP_LINK = "https://apps.apple.com/us/app/enjin-cryptocurrency-wallet/id1349078375?ls=1"

# ------------------------------------------------------------------------------
func _on_RegisterLink_pressed():
	var _r = OS.shell_open(SIGN_UP_LINK)


# ------------------------------------------------------------------------------
func _on_AndroidLink_pressed():
	var _r = OS.shell_open(ANDROID_APP_LINK)


# ------------------------------------------------------------------------------
func _on_IOSLink_pressed():
	var _r = OS.shell_open(IOS_APP_LINK)


# ------------------------------------------------------------------------------
