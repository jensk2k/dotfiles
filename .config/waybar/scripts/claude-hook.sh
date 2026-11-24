#!/bin/sh
# ~/.config/waybar/scripts/claude-hook.sh
# Run by Claude Code hooks (~/.claude/settings.json) with the event as JSON on
# stdin. Records each session's state in $XDG_RUNTIME_DIR/claude-status/<id>
# for the Waybar pill (claude.sh) and refreshes it (signal 11).
#   working  a prompt was sent, or a tool just ran
#   waiting  Claude needs you: a permission prompt or a question
#   done     the turn finished; your move
# Each file also holds the project (folder name), the claude process (so
# claude.sh can drop sessions that died without SessionEnd) and the Hyprland
# window of its terminal (for the click that focuses it).

dir="${XDG_RUNTIME_DIR:-/tmp}/claude-status"
mkdir -p "$dir"

eval "$(jq -r '@sh "sid=\(.session_id // "") event=\(.hook_event_name // "") cwd=\(.cwd // "") ntype=\(.notification_type // "") tool=\(.tool_name // "")"')"
[ -n "$sid" ] || exit 0
file="$dir/$sid"

refresh() { pkill -RTMIN+11 -x waybar; }

case "$event" in
SessionEnd) rm -f "$file"; refresh; exit 0 ;;
SessionStart) state=done ;;
UserPromptSubmit | PostToolUse) state=working ;;
PermissionRequest) state=waiting ;;
PreToolUse)
	case "$tool" in
	AskUserQuestion | ExitPlanMode) state=waiting ;;
	*) exit 0 ;;
	esac
	;;
Notification)
	case "$ntype" in
	permission_prompt | elicitation_dialog) state=waiting ;;
	*) exit 0 ;;
	esac
	;;
Stop) state=done ;;
*) exit 0 ;;
esac

old_state= pid= window=
[ -r "$file" ] && . "$file"
# Tools run all the time: only rewrite and refresh when the state changes
[ "$state" = "$old_state" ] && exit 0

# The claude process: the first ancestor named claude
if [ -z "$pid" ]; then
	p=$PPID
	while [ "${p:-1}" -gt 1 ]; do
		if [ "$(cat /proc/$p/comm 2>/dev/null)" = claude ]; then pid=$p; break; fi
		p=$(awk '{print $4}' /proc/$p/stat 2>/dev/null)
	done
fi
# Its terminal window: the nearest ancestor of claude that is a Hyprland client
# (none for background sessions)
if [ -z "$window" ] && [ -n "$pid" ] && command -v hyprctl >/dev/null; then
	clients=$(hyprctl -j clients 2>/dev/null)
	p=$pid
	while [ "${p:-1}" -gt 1 ] && [ -z "$window" ]; do
		window=$(printf '%s' "$clients" | jq -r --argjson p "$p" 'first(.[] | select(.pid == $p) | .address) // empty')
		p=$(awk '{print $4}' /proc/$p/stat 2>/dev/null)
	done
fi

tmp="$file.tmp"
{
	printf 'old_state=%s\n' "$state"
	printf 'since=%s\n' "$(date +%s)"
	printf 'project=%s\n' "$(basename "${cwd:-?}" | tr ' ' '-' | tr -cd '[:alnum:]._-')"
	printf 'pid=%s\n' "$pid"
	printf 'window=%s\n' "$window"
} >"$tmp" && mv "$tmp" "$file"
refresh
