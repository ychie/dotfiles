#!/bin/bash

# macOS system defaults configuration
# Applies preferred system and app settings
# Run manually or as part of a setup script

# Color variables
PRIMARY_COLOR='\033[1;33m'
ACCENT_COLOR='\033[0;34m'
INFO_COLOR='\033[0;30m'
INFO_COLOR_U='\033[4;30m'
SUCCESS_COLOR='\033[0;32m'
WARN_1='\033[1;31m'
WARN_2='\033[0;31m'
RESET_COLOR='\033[0m'

# Vzariables for system preferences
COMPUTER_NAME="dejevin"
HIGHLIGHT_COLOR="0 0.8 0.7"

# Check have got admin privilages
if [ "$EUID" -ne 0 ]; then
  echo -e "${ACCENT_COLOR}\nElevated permissions are required to adjust system settings."
  echo -e "${PRIMARY_COLOR}Please enter your password...${RESET_COLOR}"
  script_path=$([[ "$0" = /* ]] && echo "$0" || echo "$PWD/${0#./}")
  params="--skip-intro ${params}"
  sudo "$script_path" $params || (
    echo -e "${ACCENT_COLOR}Unable to continue without sudo permissions"
    echo -e "${PRIMARY_COLOR}Exiting...${RESET_COLOR}"
    exit 1
  )
  exit 0
fi

current_event=0
total_events=177

# Helper function to log progress to console
function log_msg () {
  current_event=$(($current_event + 1))
  if [[ ! $params == *"--silent"* ]]; then
    if (("$current_event" < 10 )); then sp='0'; else sp=''; fi
    echo -e "${PRIMARY_COLOR}[${sp}${current_event}/${total_events}] ${ACCENT_COLOR}${1}${INFO_COLOR}"
  fi
}

# Helper function to log section to console
function log_section () {
  if [[ ! $params == *"--silent"* ]]; then
    echo -e "${PRIMARY_COLOR}[INFO] ${1}${INFO_COLOR}"
  fi
}

# Quit System Preferences before starting
osascript -e 'tell application "System Preferences" to quit'

# Keep script alive
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

###################
# Set Device Info #
###################
log_section "Device Info"

# Set computer name and hostname
log_msg "Set computer name"
sudo scutil --set ComputerName "$COMPUTER_NAME"

log_msg "Set remote hostname"
sudo scutil --set HostName "$COMPUTER_NAME"

log_msg "Set local hostname"
sudo scutil --set LocalHostName "$COMPUTER_NAME"

log_msg "Set SMB hostname"
sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "$COMPUTER_NAME"

############################
# Location and locale info #
############################
log_section "Local Preferences"

log_msg "Set language to English"
defaults write NSGlobalDomain AppleLanguages -array "en"

log_msg "Set locale to Ukraine"
defaults write NSGlobalDomain AppleLocale -string "uk_UA@currency=UAH"

log_msg "Set time zone to Kyiv"
sudo systemsetup -settimezone "Europe/Kyiv" > /dev/null

log_msg "Set units to metric"
defaults write NSGlobalDomain AppleMeasurementUnits -string "Centimeters"
defaults write NSGlobalDomain AppleMetricUnits -bool true

###############
# UI Settings #
###############
log_section "UI Settings"

# Set highlight color
log_msg "Set text highlight color"
defaults write NSGlobalDomain AppleHighlightColor -string "${HIGHLIGHT_COLOR}"

log_msg "Hide menu bar"
defaults write NSGlobalDomain _HIHideMenuBar -bool true

##################
# File Locations #
##################
log_section "File Locations"

log_msg "Set location to save screenshots to"
defaults write com.apple.screencapture location -string "${HOME}/Pictures/Screenshots"

log_msg "Save screenshots in .png format"
defaults write com.apple.screencapture type -string "png"

###############################################
# Saving, Opening, Printing and Viewing Files #
###############################################
log_section "Opening, Saving and Printing Files"

log_msg "Set scrollbar to always show"
defaults write NSGlobalDomain AppleShowScrollBars -string "Always"

log_msg "Set sidebar icon size to medium"
defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 2

log_msg "Set toolbar title rollover delay"
defaults write NSGlobalDomain NSToolbarTitleViewRolloverDelay -float 0

log_msg "Set increased window resize speed"
defaults write NSGlobalDomain NSWindowResizeTime -float 0.05

log_msg "Set file save dialog to expand to all files by default"
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

log_msg "Set print dialog to expand to show all by default"
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

log_msg "Set files to save to disk, not iCloud by default"
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

log_msg "Set printer app to quit once job is completed"
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

log_msg "Disables the app opening confirmation dialog"
defaults write com.apple.LaunchServices LSQuarantine -bool false

log_msg "Show ASCII control characters using caret notation in text views"
defaults write NSGlobalDomain NSTextShowsControlCharacters -bool true

#####################################
# System Power, Resuming, Lock, etc #
#####################################
log_section "System Power and Lock Screen"

log_msg "Disable waking on lid opening"
sudo pmset -a lidwake 1

log_msg "Prevent automatic restart when power restored"
sudo pmset -a autorestart 1

log_msg "Set display to sleep after 15 minutes"
sudo pmset -a displaysleep 15

log_msg "Set sysyem sleep time to 30 minutes when on battery"
sudo pmset -b sleep 30

log_msg "Set system to not sleep automatically when on mains power"
sudo pmset -c sleep 0

log_msg "Require password immediately after sleep or screensaver"
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

log_msg "Disable system wide resuming of windows"
defaults write com.apple.systempreferences NSQuitAlwaysKeepsWindows -bool false

log_msg "Disable auto termination of inactive apps"
defaults write NSGlobalDomain NSDisableAutomaticTermination -bool true

log_msg "Disable the crash reporter"
defaults write com.apple.CrashReporter DialogType -string "none"

log_msg "Add host info to the login screen"
sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName

##############################
# Sound and Display Settings #
##############################
log_section "Sound and Display"

log_msg "Increase sound quality for Bluetooth devices"
defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40

log_msg "Enable subpixel font rendering on non-Apple LCDs"
defaults write NSGlobalDomain AppleFontSmoothing -int 1

log_msg "Enable HiDPI display modes"
sudo defaults write /Library/Preferences/com.apple.windowserver DisplayResolutionEnabled -bool true

########################
# Keyboard, Text Input #
########################
log_section "Keyboard and Input"

log_msg "Disable automatic text capitalization"
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

log_msg "Disable automatic dash substitution"
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

log_msg "Disable automatic periord substitution"
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

log_msg "Disable automatic period substitution"
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

log_msg "Disable automatic spell correction"
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

log_msg "Enable full keyboard navigation in all windows"
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

log_msg "Allow modifier key to be used for mouse zooming"
defaults write com.apple.universalaccess closeViewScrollWheelToggle -bool true
defaults write com.apple.universalaccess HIDScrollZoomModifierMask -int 262144

log_msg "Follow the keyboard focus while zoomed in"
defaults write com.apple.universalaccess closeViewZoomFollowsFocus -bool true

log_msg "Set time before keys start repeating"
defaults write NSGlobalDomain InitialKeyRepeat -int 50

log_msg "Set super fast key repeat rate"
defaults write NSGlobalDomain KeyRepeat -int 8

log_msg "Set swipe scroll direction"
defaults write -g com.apple.swipescrolldirection -bool false

#####################################
# Mouse, Trackpad, Pointing Devices #
#####################################
log_section "Mouse and Trackpad"

log_msg "Enable tap to click for trackpad"
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true

log_msg "Enable tab to click for current user"
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

log_msg "Enable tap to click for the login screen"
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

log_msg "Set hot corners for trackpad"
defaults write com.apple.dock wvous-tl-corner -int 11
defaults write com.apple.dock wvous-tl-modifier -int 0
defaults write com.apple.dock wvous-bl-corner -int 2
defaults write com.apple.dock wvous-bl-modifier -int 1048576
defaults write com.apple.dock wvous-br-corner -int 5
defaults write com.apple.dock wvous-br-modifier -int 1048576
defaults write com.apple.dock wvous-tr-corner -int 0
defaults write com.apple.dock wvous-tr-modifier -int 0

# ##############################
# Spotlight Search Preferences #
# ##############################
log_section "Spotlight and Search"

# Emable / disable search locations, and indexing order
log_msg "Set Spotlight Search Locations Order"
defaults write com.apple.spotlight orderedItems -array \
	'{"enabled" = 1;"name" = "APPLICATIONS";}' \
	'{"enabled" = 1;"name" = "SYSTEM_PREFS";}' \
	'{"enabled" = 1;"name" = "DIRECTORIES";}' \
	'{"enabled" = 1;"name" = "PDF";}' \
	'{"enabled" = 0;"name" = "FONTS";}' \
	'{"enabled" = 0;"name" = "DOCUMENTS";}' \
	'{"enabled" = 0;"name" = "MESSAGES";}' \
	'{"enabled" = 0;"name" = "CONTACT";}' \
	'{"enabled" = 0;"name" = "EVENT_TODO";}' \
	'{"enabled" = 0;"name" = "IMAGES";}' \
	'{"enabled" = 0;"name" = "BOOKMARKS";}' \
	'{"enabled" = 0;"name" = "MUSIC";}' \
	'{"enabled" = 0;"name" = "MOVIES";}' \
	'{"enabled" = 0;"name" = "PRESENTATIONS";}' \
	'{"enabled" = 0;"name" = "SPREADSHEETS";}' \
	'{"enabled" = 0;"name" = "SOURCE";}' \
	'{"enabled" = 0;"name" = "MENU_DEFINITION";}' \
	'{"enabled" = 0;"name" = "MENU_OTHER";}' \
	'{"enabled" = 0;"name" = "MENU_CONVERSION";}' \
	'{"enabled" = 0;"name" = "MENU_EXPRESSION";}' \
	'{"enabled" = 0;"name" = "MENU_WEBSEARCH";}' \
	'{"enabled" = 0;"name" = "MENU_SPOTLIGHT_SUGGESTIONS";}'

# Spotlight - load new settings, enable indexing, and rebuild index
log_msg "Refreshing Spotlight"
killall mds > /dev/null 2>&1
sudo mdutil -i on / > /dev/null
sudo mdutil -E / > /dev/null

###############################
# Dock and Launchpad Settings #
###############################
log_section "Dock and Launchpad"

log_msg "Set dock position to left-hand side"
defaults write com.apple.dock orientation -string left

log_msg "Remove default apps from the dock"
defaults write com.apple.dock persistent-apps -array

log_msg "Add highlight effect to dock stacks"
defaults write com.apple.dock mouse-over-hilite-stack -bool true

log_msg "Set item size within dock stacks"
defaults write com.apple.dock tilesize -int 48

log_msg "Set dock to use genie animation"
defaults write com.apple.dock mineffect -string "genie"

log_msg "Set apps to minimize into their dock icon"
defaults write com.apple.dock minimize-to-application -bool true

log_msg "Enable spring loading, for opening files by dragging to dock"
defaults write com.apple.dock enable-spring-load-actions-on-all-items -bool true

log_msg "Enable process indicator for apps within dock"
defaults write com.apple.dock show-process-indicators -bool true

log_msg "Enable app launching animations"
defaults write com.apple.dock launchanim -bool true

log_msg "Set opening animation speed"
defaults write com.apple.dock expose-animation-duration -float 1

log_msg "Disable auntomatic rearranging of spaces"
defaults write com.apple.dock mru-spaces -bool false

log_msg "Set dock to auto-hide by default"
defaults write com.apple.dock autohide -bool true

log_msg "Set the dock's auto-hide delay to fast"
defaults write com.apple.dock autohide-delay -float 0.05

log_msg "Set the dock show / hide animation time"
defaults write com.apple.dock autohide-time-modifier -float 0.25

log_msg "Show which dock apps are hidden"
defaults write com.apple.dock showhidden -bool true

log_msg "Hide recent files from the dock"
defaults write com.apple.dock show-recents -bool false

# If DockUtil installed, then use it to remove default dock items, and add useful ones
if hash dockutil 2> /dev/null; then
  apps_to_remove_from_dock=(
    'App Store'  'Calendar' 'Contacts' 'FaceTime'
    'Keynote' 'Mail' 'Maps' 'Messages' 'Music'
    'News' 'Notes' 'Numbers'
    'Pages' 'Photos' 'Podcasts'
    'Reminders' 'TV'
  )
  apps_to_add_to_dock=(
    'kitty' 'Standard Notes' 'Xcode'
  )
  IFS=""
  # Removes useless apps from dock
  for app in ${apps_to_remove_from_dock[@]}; do
    dockutil --remove ~/Applications/${app}.app
  done
  # Adds useful apps to dock, if installed
  for app in ${apps_to_add_to_dock[@]}; do
    if [[ -d "~/Applications/${app}.app" ]]; then
      dockutil --add ~/Applications/${app}.app
    fi
  done
fi

log_msg "Add iOS Simulator to Launchpad"
sudo ln -sf "/Applications/Xcode.app/Contents/Developer/Applications/Simulator.app" "/Applications/Simulator.app"

log_msg "Add Apple Watch simulator to Launchpad"
sudo ln -sf "/Applications/Xcode.app/Contents/Developer/Applications/Simulator (Watch).app" "/Applications/Simulator (Watch).app"

log_msg "Restarting dock"
killall Dock

log_msg "Restarting system ui server"
killall SystemUIServer

# ######################################
# Disabling Siri and related features #
# ######################################
log_section "Disable Telemetry and Assistant Features"

# Disable Ask Siri
log_msg "Disable 'Ask Siri'"
defaults write com.apple.assistant.support 'Assistant Enabled' -bool false

#  Disable Siri voice feedback
log_msg "Disable Siri voice feedback"
defaults write com.apple.assistant.backedup 'Use device speaker for TTS' -int 3

# Disable "Do you want to enable Siri?" pop-up
log_msg "Disable 'Do you want to enable Siri?' pop-up"
defaults write com.apple.SetupAssistant 'DidSeeSiriSetup' -bool True

# Hide Siri from menu bar
log_msg "Hide Siri from menu bar"
defaults write com.apple.systemuiserver 'NSStatusItem Visible Siri' 0

# Hide Siri from status menu
log_msg "Hide Siri from status menu"
defaults write com.apple.Siri 'StatusMenuVisible' -bool false
defaults write com.apple.Siri 'UserHasDeclinedEnable' -bool true

# Opt-out from Siri data collection
log_msg "Opt-out from Siri data collection"
defaults write com.apple.assistant.support 'Siri Data Sharing Opt-In Status' -int 2

# Don't prompt user to report crashes, may leak sensitive info
log_msg "Disable crash reporter"
defaults write com.apple.CrashReporter DialogType none

############################
# MacOS Firefwall Security #
############################
log_section "Firewall Config"

# Prevent automatically allowing incoming connections to signed apps
log_msg "Prevent automatically allowing incoming connections to signed apps"
sudo defaults write /Library/Preferences/com.apple.alf allowsignedenabled -bool false

# Prevent automatically allowing incoming connections to downloaded signed apps
log_msg "Prevent automatically allowing incoming connections to downloaded signed apps"
sudo defaults write /Library/Preferences/com.apple.alf allowdownloadsignedenabled -bool false

# Enable application firewall
log_msg "Enable application firewall"
/usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
sudo defaults write /Library/Preferences/com.apple.alf globalstate -bool true
defaults write com.apple.security.firewall EnableFirewall -bool true

# Turn on firewall logging
log_msg "Turn on firewall logging"
/usr/libexec/ApplicationFirewall/socketfilterfw --setloggingmode on
sudo defaults write /Library/Preferences/com.apple.alf loggingenabled -bool true

# Turn on stealth mode
log_msg "Turn on stealth mode"
/usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on
sudo defaults write /Library/Preferences/com.apple.alf stealthenabled -bool true
defaults write com.apple.security.firewall EnableStealthMode -bool true

# Will prompt user to allow network access even for signed apps
log_msg "Prevent signed apps from being automatically whitelisted"
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setallowsigned off

# Will prompt user to allow network access for downloaded apps
log_msg "Prevent downloaded apps from being automatically whitelisted"
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setallowsignedapp off

# Sending hangup command to socketfilterfw is required for changes to take effect
log_msg "Restarting socket filter firewall"
sudo pkill -HUP socketfilterfw

####################################
# Log In and User Account Security #
####################################
log_section "Account Security"

# Enforce system hibernation
log_msg "Enforce hibernation instead of sleep"
sudo pmset -a destroyfvkeyonstandby 1

# Require a password to wake the computer from sleep or screen saver
log_msg "Require a password to wake the computer from sleep or screen saver"
sudo defaults write /Library/Preferences/com.apple.screensaver askForPassword -bool true

# Initiate session lock five seconds after screen saver is started
log_msg "Initiate session lock five seconds after screen saver is started"
sudo defaults write /Library/Preferences/com.apple.screensaver 'askForPasswordDelay' -int 5

# Disables signing in as Guest from the login screen
log_msg "Disables signing in as Guest from the login screen"
sudo defaults write /Library/Preferences/com.apple.loginwindow GuestEnabled -bool NO

# Disables Guest access to file shares over AF
log_msg "Disables Guest access to file shares over AF"
sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server AllowGuestAccess -bool NO

####################################
# Prevent Unauthorized Connections #
####################################
log_section "Prevent Unauthorized Connections"

# Disables Guest access to file shares over SMB
log_msg "Disables Guest access to file shares over SMB"
sudo defaults write /Library/Preferences/com.apple.AppleFileServer guestAccess -bool NO

# Disable remote login (incoming SSH and SFTP connections)
log_msg "Disable remote login (incoming SSH and SFTP connections)"
echo 'yes' | sudo systemsetup -setremotelogin off

# Disable insecure TFTP service
log_msg "Disable insecure TFTP service"
sudo launchctl disable 'system/com.apple.tftpd'

# Disable insecure telnet protocol
log_msg "Disable insecure telnet protocol"
sudo launchctl disable system/com.apple.telnetd

log_msg "Prevent auto-launching captive portal webpages"
sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.captive.control.plist Active -bool false

#########################################
# Disable Printers and Sharing Protocols #
#########################################
log_section "Printers and Sharing Protocols"

# Disable sharing of local printers with other computers
log_msg "Disable sharing of local printers with other computers"
cupsctl --no-share-printers

# Disable printing from any address including the Internet
log_msg "Disable printing from any address including the Internet"
cupsctl --no-remote-any

# Disable remote printer administration
log_msg "Disable remote printer administration"
cupsctl --no-remote-admin

# Disable Captive portal
log_msg "Disable Captive portal"
sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.captive.control.plist Active -bool false

##########
# Finder #
##########
log_section "Finder"

log_msg "Open new tabs to Home"
defaults write com.apple.finder NewWindowTarget -string "PfHm"

log_msg "Open new windows to file root"
defaults write com.apple.finder NewWindowTargetPath -string "file:///"

log_msg "Show hidden files"
defaults write com.apple.finder AppleShowAllFiles -bool true

log_msg "Show file extensions"
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

log_msg "View all network locations"
defaults write com.apple.NetworkBrowser BrowseAllInterfaces -bool true

log_msg "Show the ~/Library folder"
chflags nohidden ~/Library && xattr -d com.apple.FinderInfo ~/Library

log_msg "Show the /Volumes folder"
chflags nohidden /Volumes

log_msg "Allow finder to be fully quitted with ⌘ + Q"
defaults write com.apple.finder QuitMenuItem -bool true

log_msg "Show the status bar in Finder"
defaults write com.apple.finder ShowStatusBar -bool true

log_msg "Show the path bar in finder"
defaults write com.apple.finder ShowPathbar -bool true

log_msg "Display full POSIX path as Finder window title"
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

log_msg "Expand the General, Open and Privileges file info panes"
defaults write com.apple.finder FXInfoPanesExpanded -dict \
	General -bool true \
	OpenWith -bool true \
	Privileges -bool true

log_msg "Keep directories at top of search results"
defaults write com.apple.finder _FXSortFoldersFirst -bool true

log_msg "Search current directory by default"
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

log_msg "Don't show warning when changing extension"
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

log_msg "Don't add .DS_Store to network drives"
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

log_msg "Don't add .DS_Store to USB devices"
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

log_msg "Open a new Finder window when a volume is mounted"
defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true
defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true

log_msg "Open a new Finder window when a disk is mounted"
defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool true


log_msg "Show item info"
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:showItemInfo true" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:showItemInfo true" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:showItemInfo true" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set DesktopViewSettings:IconViewSettings:labelOnBottom false" ~/Library/Preferences/com.apple.finder.plist

log_msg "Enable snap-to-grid for icons on the desktop and finder"
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist

log_msg "Set grid spacing for icons on the desktop and finder"
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:gridSpacing 100" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:gridSpacing 100" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:gridSpacing 100" ~/Library/Preferences/com.apple.finder.plist

log_msg "Set icon size on desktop and in finder"
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:iconSize 80" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:iconSize 80" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:iconSize 80" ~/Library/Preferences/com.apple.finder.plist

########################################
# Safari & Webkit Privacy Enchanements #
########################################
log_section "Safari and Webkit"

log_msg "Don't send search history to Apple"
defaults write com.apple.Safari UniversalSearchEnabled -bool false
defaults write com.apple.Safari SuppressSearchSuggestions -bool true

log_msg "Allow using tab to highlight elements"
defaults write com.apple.Safari WebKitTabToLinksPreferenceKey -bool true
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2TabsToLinks -bool true

log_msg "Show full URL"
defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true

log_msg "Set homepage"
defaults write com.apple.Safari HomePage -string "about:blank"

log_msg "Don't open downloaded files automatically"
defaults write com.apple.Safari AutoOpenSafeDownloads -bool false

log_msg "Hide favorites bar"
defaults write com.apple.Safari ShowFavoritesBar -bool false

log_msg "Hide sidebar"
defaults write com.apple.Safari ShowSidebarInTopSites -bool false

log_msg "Disable thumbnail cache"
defaults write com.apple.Safari DebugSnapshotsUpdatePolicy -int 2

log_msg "Enable debug menu"
defaults write com.apple.Safari IncludeInternalDebugMenu -bool true

log_msg "Search feature matches any part of word"
defaults write com.apple.Safari FindOnPageMatchesWordStartsOnly -bool false

log_msg "Remove unneeded icons from bookmarks bar"
defaults write com.apple.Safari ProxiesInBookmarksBar "()"

log_msg "Enable developer options"
defaults write com.apple.Safari IncludeDevelopMenu -bool true
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true
defaults write NSGlobalDomain WebKitDeveloperExtras -bool true

log_msg "Enable spell check"
defaults write com.apple.Safari WebContinuousSpellCheckingEnabled -bool true

log_msg "Disable auto-correct"
defaults write com.apple.Safari WebAutomaticSpellingCorrectionEnabled -bool false

log_msg "Disable auto-fill addressess"
defaults write com.apple.Safari AutoFillFromAddressBook -bool false

log_msg "Disable auto-fill passwords"
defaults write com.apple.Safari AutoFillPasswords -bool false

log_msg "Disable auto-fill credit cards"
defaults write com.apple.Safari AutoFillCreditCardData -bool false

log_msg "Disable auto-fill misc forms"
defaults write com.apple.Safari AutoFillMiscellaneousForms -bool false

log_msg "Enable fraud warnings"
defaults write com.apple.Safari WarnAboutFraudulentWebsites -bool true

log_msg "Disable web plugins"
defaults write com.apple.Safari WebKitPluginsEnabled -bool false
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2PluginsEnabled -bool false

log_msg "Disable Java"
defaults write com.apple.Safari WebKitJavaEnabled -bool false
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaEnabled -bool false
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaEnabledForLocalFiles -bool false

log_msg "Prevent pop-ups"
defaults write com.apple.Safari WebKitJavaScriptCanOpenWindowsAutomatically -bool false
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaScriptCanOpenWindowsAutomatically -bool false

log_msg "Dissallow auto-play"
defaults write com.apple.Safari WebKitMediaPlaybackAllowsInline -bool false
defaults write com.apple.SafariTechnologyPreview WebKitMediaPlaybackAllowsInline -bool false
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2AllowsInlineMediaPlayback -bool false
defaults write com.apple.SafariTechnologyPreview com.apple.Safari.ContentPageGroupIdentifier.WebKit2AllowsInlineMediaPlayback -bool false

log_msg "Use Do not Track header"
defaults write com.apple.Safari SendDoNotTrackHTTPHeader -bool true

log_msg "Don't auto-update Extensions"
defaults write com.apple.Safari InstallExtensionUpdatesAutomatically -bool false

##################
# Apple Mail App #
##################
log_section "Apple Mail App"

log_msg "Copy only email address, not name"
defaults write com.apple.mail AddressesIncludeNameOnPasteboard -bool false

log_msg "Use ⌘ + Enter shortcut to quick send emails"
defaults write com.apple.mail NSUserKeyEquivalents -dict-add "Send" "@\U21a9"

log_msg "Display messages in thread mode"
defaults write com.apple.mail DraftsViewerAttributes -dict-add "DisplayInThreadedMode" -string "yes"

log_msg "Sort messages by date"
defaults write com.apple.mail DraftsViewerAttributes -dict-add "SortOrder" -string "received-date"

log_msg "Sort by newest to oldest"
defaults write com.apple.mail DraftsViewerAttributes -dict-add "SortedDescending" -string "yes"

log_msg "Disable inline attachment viewing"
defaults write com.apple.mail DisableInlineAttachmentViewing -bool true

################
# Terminal App #
################
log_section "Terminal App"

log_msg "Set Terminal to only use UTF-8"
defaults write com.apple.terminal StringEncodings -array 4

log_msg "Enable secure entry for Terminal"
defaults write com.apple.terminal SecureKeyboardEntry -bool true

###############################################################################
# Time Machine                                                                #
###############################################################################
log_section "Time Machine"

log_msg "Prevent Time Machine prompting to use new drive as backup"
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

###############################################################################
# Activity Monitor                                                            #
###############################################################################
log_section "Activity Monitor"

log_msg "Show the main window when launching Activity Monitor"
defaults write com.apple.ActivityMonitor OpenMainWindow -bool true

log_msg "Visualize CPU usage in the Activity Monitor Dock icon"
defaults write com.apple.ActivityMonitor IconType -int 5

log_msg "Show all processes in Activity Monitor"
defaults write com.apple.ActivityMonitor ShowCategory -int 0

log_msg "Sort results by CPU usage"
defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
defaults write com.apple.ActivityMonitor SortDirection -int 0

###################
# Apple Mac Store #
###################
log_section "Apple Mac Store"

log_msg "Allow automatic update checks"
defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true

log_msg "Auto install criticial security updates"
defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -int 1

log_msg "Enable the debug menu"
defaults write com.apple.appstore ShowDebugMenu -bool true

log_msg "Enable extra dev tools"
defaults write com.apple.appstore WebKitDeveloperExtras -bool true

####################
# Apple Photos App #
####################
log_section "Apple Photos App"

log_msg "Prevent Photos from opening automatically when devices are plugged in"
defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true

######################
# Apple Messages App #
######################
log_section "Apple Messages App"

log_msg "Disable automatic emoji substitution"
defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "automaticEmojiSubstitutionEnablediMessage" -bool false

log_msg "Disable smart quotes"
defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "automaticQuoteSubstitutionEnabled" -bool false

#############################################################
# Address Book, Dashboard, iCal, TextEdit, and Disk Utility #
#############################################################
log_section "Address Book, Calendar, TextEdit"

log_msg "Enable the debug menu in Address Book"
defaults write com.apple.addressbook ABShowDebugMenu -bool true

log_msg "Enable Dashboard dev mode"
defaults write com.apple.dashboard devmode -bool true

log_msg "Use plaintext for new text documents"
defaults write com.apple.TextEdit RichText -int 0

log_msg "Use UTF-8 for opening text files"
defaults write com.apple.TextEdit PlainTextEncoding -int 4

log_msg "Use UTF-8 for saving text files"
defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4

log_msg "Enable the debug menu in Disk Utility"
defaults write com.apple.DiskUtility DUDebugMenuEnabled -bool true
defaults write com.apple.DiskUtility advanced-image-options -bool true

log_msg "Auto-play videos when opened with QuickTime Player"
defaults write com.apple.QuickTimePlayerX MGPlayMovieOnOpen -bool true

#################################
# Restart affected applications #
#################################
log_section "Finishing Up"
log_msg "Restarting affecting apps"
for app in "Activity Monitor" \
	"Address Book" \
	"Calendar" \
	"Contacts" \
	"Finder" \
	"Mail" \
	"Messages" \
	"Photos" \
	"Safari" \
	"Terminal" \
	"iCal"; do
	killall "${app}" &> /dev/null
done

#####################################
# Print finishing message, and exit #
#####################################
echo -e "${PRIMARY_COLOR}\nFinishing...${RESET_COLOR}"
echo -e "${SUCCESS_COLOR}✔ ${current_event}/${total_events} tasks were completed \
succesfully in $((`date +%s`-start_time)) seconds${RESET_COLOR}"
echo -e "\n${PRIMARY_COLOR}         .:'\n     __ :'__\n  .'\`__\`-'__\`\`.\n \
:__________.-'\n :_________:\n  :_________\`-;\n   \`.__.-.__.'\n${RESET_COLOR}"

if [[ ! $params == *"--quick-exit"* ]]; then
  echo -e "${ACCENT_COLOR}Press any key to continue.${RESET_COLOR}"
  read -t 5 -n 1 -s
fi
exit 0
