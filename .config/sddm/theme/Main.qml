// ~/.config/sddm/theme/Main.qml
// Login screen for SDDM (Qt 6), built around background.png (a retro blue
// collage: a wizard on the left, an ASCII-art Mona Lisa on the right). The
// image is shown as is; everything else is written in the ASCII art's style
// (JetBrains Mono 18 px, the art's red/cyan colour fringe, NAME:: labels):
//   - left: the prompt, floating in the sky the wizard points at
//   - right: the time as big ASCII-art digits (hours above minutes) drawn
//     into the dotted lower right of the Mona Lisa, the date in its bottom row
// Colours and font come from theme.conf. Positions are in image pixels
// (1920x1080); the stage scales like the image (cover).
import QtQuick

Rectangle {
	id: root
	width: 1920
	height: 1080
	color: config.Blue

	property int sessionIndex: sessionModel.lastIndex
	property string sessionName: ""
	property string userName: userModel.lastUser
	property string host: sddm.hostName ? sddm.hostName : ""
	property string status: "idle"   // idle | busy | failed
	property bool blink: true
	property int dots: 0
	property string timeText: Qt.formatTime(new Date(), "HH:mm")
	property string dateText: Qt.formatDate(new Date(), "ddd dd.MM.yyyy")
	property bool alert: status === "failed" || keyboard.capsLock

	function login() {
		if (password.text === "")
			return
		status = "busy"
		sddm.login(userName, password.text, sessionIndex)
	}

	// Always start the uwsm-managed Hyprland session when it exists
	Repeater {
		model: sessionModel
		delegate: Item {
			Component.onCompleted: if (model.file.indexOf("uwsm") !== -1) { root.sessionIndex = index; root.sessionName = model.name }
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
			root.status = "failed"
			shake.restart()
			password.forceActiveFocus()
		}
	}

	// Text with the ASCII art's colour fringe: cyan and magenta copies
	// offset to either side of the mint text
	component Fringe: Item {
		property alias text: main.text
		property alias color: main.color
		property alias bold: main.font.bold
		property real spread: 1.2
		width: main.implicitWidth
		height: main.implicitHeight
		Text { x: -parent.spread; text: main.text; font: main.font; color: config.Cyan; opacity: 0.7 }
		Text { x: parent.spread; text: main.text; font: main.font; color: config.Magenta; opacity: 0.8 }
		Text { id: main; color: config.Text; font.family: config.Font; font.pixelSize: 18 }
	}

	// Fringed text that works as a button
	component AsciiButton: Fringe {
		signal clicked
		color: area.containsMouse ? config.Text : config.Dim
		MouseArea {
			id: area
			anchors.fill: parent
			anchors.margins: -3
			hoverEnabled: true
			cursorShape: Qt.PointingHandCursor
			onClicked: parent.clicked()
		}
	}

	// A fringed line on a strip of the image's blue, so it reads on top of
	// the ASCII art
	component Strip: Rectangle {
		property alias text: label.text
		height: 20
		width: label.width + 12
		color: config.Blue
		Fringe { id: label; x: 6; anchors.verticalCenter: parent.verticalCenter; color: config.Line }
	}

	Item {
		id: stage
		width: 1920
		height: 1080
		anchors.centerIn: parent
		scale: Math.max(root.width / 1920, root.height / 1080)

		// The ASCII art's character grid, measured from the image: 65
		// columns of 10.81 px from x 1046.2, 47 rows of 20 px from y 68
		readonly property real cellW: 10.81
		readonly property real gridX: 1046.2
		readonly property real gridY: 68

		// 5x7 bitmap digits for the clock
		readonly property var glyphs: ({
			"0": [" ### ", "#   #", "#  ##", "# # #", "##  #", "#   #", " ### "],
			"1": ["  #  ", " ##  ", "  #  ", "  #  ", "  #  ", "  #  ", " ### "],
			"2": [" ### ", "#   #", "    #", "   # ", "  #  ", " #   ", "#####"],
			"3": [" ### ", "#   #", "    #", "  ## ", "    #", "#   #", " ### "],
			"4": ["   # ", "  ## ", " # # ", "#  # ", "#####", "   # ", "   # "],
			"5": ["#####", "#    ", "#### ", "    #", "    #", "#   #", " ### "],
			"6": [" ### ", "#    ", "#    ", "#### ", "#   #", "#   #", " ### "],
			"7": ["#####", "    #", "   # ", "  #  ", " #   ", " #   ", " #   "],
			"8": [" ### ", "#   #", "#   #", " ### ", "#   #", "#   #", " ### "],
			"9": [" ### ", "#   #", "#   #", " ####", "    #", "    #", " ### "],
			":": [" ", " ", "#", " ", "#", " ", " "]
		})
		// The 7 text rows of a string in the bitmap font: every lit pixel
		// is two "M" cells wide (square, as the cells are about twice as tall
		// as wide), unlit ones are spaces so the art's dots show through; two
		// empty cells between glyphs. Two digits are 22 cells wide.
		function bitmapRows(t) {
			var rows = []
			for (var r = 0; r < 7; r++) {
				var s = ""
				for (var i = 0; i < t.length; i++) {
					var g = glyphs[t[i]][r]
					for (var c = 0; c < g.length; c++)
						s += g[c] === "#" ? "MM" : "  "
					if (i < t.length - 1)
						s += "  "
				}
				rows.push(s)
			}
			return rows
		}

		Image { anchors.fill: parent; source: config.Background }

		// ---- Right: hours above minutes in the dotted lower right
		// (columns 42-63, rows 30-36 and 38-44), the date in the bottom
		// row (46) ----
		Repeater {
			model: root.timeText.split(":")
			Item {
				id: block
				property var rows: stage.bitmapRows(modelData)
				x: stage.gridX + 42 * stage.cellW
				y: stage.gridY + (30 + index * 8) * 20
				Repeater {
					model: block.rows
					Fringe {
						y: index * 20
						text: modelData
						spread: 1.4
						bold: true
					}
				}
			}
		}
		Strip {
			x: stage.gridX + 65 * stage.cellW - width
			y: stage.gridY + 46 * 20
			text: "SYS::" + root.dateText.toUpperCase()
		}

		// ---- Left: the prompt, in open sky below the little windows ----
		Column {
			x: 505
			y: 446
			spacing: 3

			Fringe { text: "USR::" + root.userName.toUpperCase() + (root.host ? "@" + root.host.toUpperCase() : "") }
			Fringe { text: "> SPEAK THE WORD, TRAVELLER"; color: config.Line }

			Row {
				Fringe { text: "PWD::" }
				TextInput {
					id: password
					width: 260
					focus: true
					clip: true
					echoMode: TextInput.Password
					passwordCharacter: "*"
					color: config.Text
					selectionColor: config.Line
					selectedTextColor: config.Blue
					font.family: config.Font
					font.pixelSize: 18
					cursorDelegate: Rectangle {
						width: 10
						height: 20
						color: config.Text
						visible: root.blink && password.activeFocus
					}
					onTextEdited: if (root.status === "failed") root.status = "idle"
					onAccepted: root.login()
					Keys.onEscapePressed: text = ""
					Keys.onPressed: (event) => {
						if (event.key === Qt.Key_F1 && sddm.canReboot) sddm.reboot()
						else if (event.key === Qt.Key_F2 && sddm.canPowerOff) sddm.powerOff()
					}
				}
				// A wrong password shakes the line, like a fizzled spell
				SequentialAnimation on x {
					id: shake
					running: false
					NumberAnimation { to: -10; duration: 45 }
					NumberAnimation { to: 10; duration: 70 }
					NumberAnimation { to: -6; duration: 60 }
					NumberAnimation { to: 4; duration: 50 }
					NumberAnimation { to: 0; duration: 40 }
				}
			}

			// Status: always one line, so nothing below it jumps
			Fringe {
				color: root.alert ? config.Magenta : config.Dim
				text: root.status === "failed" ? "> THE WORD IS WRONG"
					: root.status === "busy" ? "> AUTHENTICATING" + ".".repeat(root.dots % 4)
					: keyboard.capsLock ? "> CAPS LOCK ON"
					: " "
			}

			Item { width: 1; height: 6 }

			// Power keys (also clickable) and the session that will start
			Row {
				spacing: 14
				AsciiButton { text: "F1:REBOOT"; visible: sddm.canReboot; onClicked: sddm.reboot() }
				AsciiButton { text: "F2:HALT"; visible: sddm.canPowerOff; onClicked: sddm.powerOff() }
				Fringe {
					color: config.Dim
					// "Hyprland (uwsm-managed)" -> "HYPRLAND"
					text: ">> " + (root.sessionName ? root.sessionName.replace(/\s*\(.*\)/, "").toUpperCase() : "HYPRLAND")
				}
			}
		}
	}

	Timer {
		interval: 530
		running: true
		repeat: true
		onTriggered: {
			root.blink = !root.blink
			root.timeText = Qt.formatTime(new Date(), "HH:mm")
			root.dateText = Qt.formatDate(new Date(), "ddd dd.MM.yyyy")
		}
	}
	Timer {
		interval: 350
		running: root.status === "busy"
		repeat: true
		onTriggered: root.dots++
	}

	Component.onCompleted: password.forceActiveFocus()
}
