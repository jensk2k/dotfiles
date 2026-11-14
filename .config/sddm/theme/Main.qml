// ~/.config/sddm/theme/Main.qml
// Login screen for SDDM (Qt 6), built around background.png (a retro blue
// collage: a wizard on the left, an ASCII-art Mona Lisa on the right). The
// image is shown as is; everything else is written in the ASCII art's style
// (JetBrains Mono 18 px, the art's red/cyan colour fringe, NAME:: labels):
//   - left: the prompt, floating in the sky the wizard points at
//   - right: the time as big ASCII-art digits (hours above minutes) drawn
//     into the dotted lower right of the Mona Lisa, the date in its bottom row
// Animations, all in the same retro spirit: the prompt types itself out
// when the screen appears, the clock decodes through random characters of
// the art's set on start and every minute change, and now and then the
// colour fringe on all text glitches like interference on an old screen.
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

	// Typing intro: characters of the prompt shown so far
	property int typed: 0
	readonly property int typeTotal: line1.text.length + line2.text.length + line3.text.length
	readonly property bool typedOut: typed >= typeTotal
	// Characters [start, start + len) of the intro that are visible
	function reveal(start, len) { return Math.max(0, Math.min(len, typed - start)) }
	// Clock decoding: ticks left (counting down) and a counter that makes
	// the scrambled text re-roll on every tick
	property int scramble: 0
	property int noise: 0
	// Signal glitch: 0 = calm, 1 = fringe pulled far apart
	property real glitch: 0
	// Tear direction/size, re-rolled at every step of a glitch
	property real tearSeed: 1

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
	// (glitches pull the copies apart). `shown` limits it to the first
	// characters, for the typing intro (-1 = all).
	component Fringe: Item {
		property string text
		property int shown: -1
		property alias color: main.color
		property alias bold: main.font.bold
		property real spread: 1.2
		readonly property real offset: spread + root.glitch * 14
		// Each line tears sideways its own way during a glitch
		readonly property real tear: root.glitch * root.tearSeed * (10 + (text.length % 7) * 3) * (text.length % 2 ? 1 : -1)
		width: main.implicitWidth
		height: main.implicitHeight
		Text { x: parent.tear - parent.offset; text: main.text; font: main.font; color: config.Cyan; opacity: 0.7 }
		Text { x: parent.tear + parent.offset; text: main.text; font: main.font; color: config.Magenta; opacity: 0.8 }
		Text {
			id: main
			x: parent.tear
			text: parent.shown < 0 ? parent.text : parent.text.substring(0, parent.shown)
			color: config.Text
			font.family: config.Font
			font.pixelSize: 18
		}
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
		// A clock row while decoding: each lit cell is a random character
		// of the art's set, with fewer of them as the ticks run out, so the
		// digits settle in. `noise` only forces a re-roll per tick.
		readonly property string charset: "iIlYVXRBMW#%=+"
		function scrambled(row, ticks, noise) {
			var out = ""
			for (var i = 0; i < row.length; i++)
				out += row[i] === "M" && Math.random() < ticks / 12
					? charset[Math.floor(Math.random() * charset.length)] : row[i]
			return out
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
						text: root.scramble > 0 ? stage.scrambled(modelData, root.scramble, root.noise) : modelData
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

			Fringe {
				id: line1
				text: "USR::" + root.userName.toUpperCase() + (root.host ? "@" + root.host.toUpperCase() : "")
				shown: root.reveal(0, text.length)
			}
			Fringe {
				id: line2
				text: "> SPEAK THE WORD, TRAVELLER"
				shown: root.reveal(line1.text.length, text.length)
				color: config.Line
			}

			Row {
				Fringe {
					id: line3
					text: "PWD::"
					shown: root.reveal(line1.text.length + line2.text.length, text.length)
				}
				TextInput {
					id: password
					width: 260
					// Can be typed into at once; shows up when the intro is done
					opacity: root.typedOut ? 1 : 0
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
				opacity: root.typedOut ? 1 : 0
				Behavior on opacity { NumberAnimation { duration: 400 } }
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

	// Typing intro, about 28 ms per character; then the clock decodes
	NumberAnimation on typed {
		id: intro
		from: 0
		to: root.typeTotal
		duration: root.typeTotal * 28
		onFinished: root.scramble = 12
	}
	// Decode the clock on every minute change (and when the intro ends)
	onTimeTextChanged: scramble = 12
	Timer {
		interval: 50
		running: root.scramble > 0
		repeat: true
		onTriggered: { root.noise++; root.scramble-- }
	}
	// Signal glitch: first one after ~4 s, then every 10-20 s
	SequentialAnimation {
		id: glitchAnim
		ScriptAction { script: root.tearSeed = Math.random() * 2 - 1 }
		NumberAnimation { target: root; property: "glitch"; to: 1; duration: 40 }
		PauseAnimation { duration: 60 }
		ScriptAction { script: root.tearSeed = Math.random() * 2 - 1 }
		NumberAnimation { target: root; property: "glitch"; to: 0.3; duration: 50 }
		ScriptAction { script: root.tearSeed = Math.random() * 2 - 1 }
		NumberAnimation { target: root; property: "glitch"; to: 0.9; duration: 40 }
		PauseAnimation { duration: 60 }
		NumberAnimation { target: root; property: "glitch"; to: 0; duration: 200 }
	}
	Timer {
		interval: 4000
		running: true
		repeat: true
		onTriggered: {
			glitchAnim.restart()
			interval = 10000 + Math.random() * 10000
		}
	}

	Component.onCompleted: password.forceActiveFocus()
}
