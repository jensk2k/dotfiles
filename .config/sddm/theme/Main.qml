// ~/.config/sddm/theme/Main.qml
// Login screen for SDDM (Qt 6): blurred wallpaper, clock, password field and
// power buttons, like hyprlock. Colours come from theme.conf.user (generated
// by ~/.config/theme/apply), layout settings from theme.conf.
import QtQuick
import QtQuick.Controls
import QtQuick.Effects

Rectangle {
	id: root
	width: 1920
	height: 1080
	color: config.Bg

	property int sessionIndex: sessionModel.lastIndex
	property string sessionName: ""
	property string userName: userModel.lastUser
	property bool failed: false

	function login() {
		failed = false
		sddm.login(userName, password.text, sessionIndex)
	}

	// Always start the uwsm-managed Hyprland session when it exists
	Repeater {
		model: sessionModel
		delegate: Item {
			Component.onCompleted: {
				if (model.file.indexOf("uwsm") !== -1) {
					root.sessionIndex = index
					root.sessionName = model.name
				}
			}
		}
	}

	// Fall back to the first user when SDDM doesn't remember the last one
	Repeater {
		model: userModel
		delegate: Item {
			Component.onCompleted: if (root.userName === "" && index === 0) root.userName = model.name
		}
	}

	Connections {
		target: sddm
		function onLoginFailed() {
			password.text = ""
			root.failed = true
			password.forceActiveFocus()
		}
	}

	// Background: blurred, slightly darkened wallpaper
	Image {
		id: wallpaper
		anchors.fill: parent
		source: config.Background
		fillMode: Image.PreserveAspectCrop
		visible: false
	}
	MultiEffect {
		anchors.fill: parent
		source: wallpaper
		autoPaddingEnabled: false
		blurEnabled: true
		blur: 1.0
		blurMax: Number(config.Blur)
	}
	Rectangle {
		anchors.fill: parent
		color: config.Bg
		opacity: 0.4
	}

	Column {
		anchors.centerIn: parent
		anchors.verticalCenterOffset: -40
		spacing: 12

		Text {
			id: clock
			anchors.horizontalCenter: parent.horizontalCenter
			color: config.Fg
			font.family: config.Font
			font.pixelSize: 120
			text: Qt.formatTime(new Date(), "HH:mm")
		}

		// Danish-style day.month.year, like the bar and lock screen
		Text {
			id: date
			anchors.horizontalCenter: parent.horizontalCenter
			color: config.Fg
			font.family: config.Font
			font.pixelSize: 26
			text: Qt.formatDate(new Date(), "dddd dd.MM.yyyy")
		}

		Item { width: 1; height: 48 }

		Text {
			anchors.horizontalCenter: parent.horizontalCenter
			color: config.Dim
			font.family: config.Font
			font.pixelSize: 20
			text: "󰀄  " + root.userName
		}

		TextField {
			id: password
			anchors.horizontalCenter: parent.horizontalCenter
			width: 380
			height: 52
			focus: true
			echoMode: TextInput.Password
			horizontalAlignment: TextInput.AlignHCenter
			color: config.Fg
			font.family: config.Font
			font.pixelSize: 20
			placeholderText: "Password..."
			placeholderTextColor: config.Dim
			background: Rectangle {
				radius: 6
				color: config.Surface
				opacity: 0.9
				border.width: 2
				border.color: root.failed ? config.Crit : (password.activeFocus ? config.Accent : config.Dim)
			}
			onTextEdited: root.failed = false
			onAccepted: root.login()
			Keys.onEscapePressed: text = ""
		}

		Text {
			anchors.horizontalCenter: parent.horizontalCenter
			color: root.failed ? config.Crit : config.Warn
			font.family: config.Font
			font.pixelSize: 16
			text: root.failed ? "Wrong password" : (keyboard.capsLock ? "Caps Lock is on" : " ")
		}
	}

	// Session name, bottom left
	Text {
		anchors.left: parent.left
		anchors.bottom: parent.bottom
		anchors.margins: 32
		color: config.Dim
		font.family: config.Font
		font.pixelSize: 16
		text: root.sessionName
	}

	// Reboot and shut down, bottom right
	Row {
		anchors.right: parent.right
		anchors.bottom: parent.bottom
		anchors.margins: 32
		spacing: 28

		Repeater {
			model: [
				{ icon: "󰜉", label: "Reboot", action: function () { sddm.reboot() }, enabled: sddm.canReboot },
				{ icon: "󰐥", label: "Shut down", action: function () { sddm.powerOff() }, enabled: sddm.canPowerOff },
			]
			delegate: Text {
				visible: modelData.enabled
				color: area.containsMouse ? config.Accent : config.Fg
				font.family: config.Font
				font.pixelSize: 28
				text: modelData.icon

				MouseArea {
					id: area
					anchors.fill: parent
					anchors.margins: -8
					hoverEnabled: true
					cursorShape: Qt.PointingHandCursor
					onClicked: modelData.action()
				}
				ToolTip.visible: area.containsMouse
				ToolTip.text: modelData.label
			}
		}
	}

	Timer {
		interval: 1000
		running: true
		repeat: true
		onTriggered: {
			clock.text = Qt.formatTime(new Date(), "HH:mm")
			date.text = Qt.formatDate(new Date(), "dddd dd.MM.yyyy")
		}
	}

	Component.onCompleted: password.forceActiveFocus()
}
