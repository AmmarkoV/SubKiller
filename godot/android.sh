#!/bin/bash
# Rebuild SubKiller and install it on every phone adb can see.
#
#   ./android.sh            rebuild + install
#   ./android.sh --run      rebuild + install + launch it
#
# Override the engine with  GODOT=/path/to/godot ./android.sh

set -u

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GODOT="${GODOT:-/home/ammar/Programs/Godot_v4.7.1-stable_linux.x86_64}"
PRESET="${PRESET:-Android}"
APK="$HERE/SubKiller.apk"
PACKAGE="org.godotengine.subkiller"
LAUNCH=0

for arg in "$@"; do
	case "$arg" in
		-r|--run)  LAUNCH=1 ;;
		-h|--help) sed -n '2,8p' "$0" | cut -c3- ; exit 0 ;;
		*) echo "android.sh: unknown option $arg (try --help)" >&2; exit 1 ;;
	esac
done

die() { echo "android.sh: $*" >&2; exit 1; }

#---------------------------------------------------------------- engine checks
[ -x "$GODOT" ] || GODOT="$(command -v godot 2>/dev/null)" || true
[ -n "$GODOT" ] && [ -x "$GODOT" ] || die "no Godot binary, set GODOT=/path/to/godot"

VERSION="$("$GODOT" --version 2>/dev/null | tail -1)"     # 4.7.1.stable.official.abcdef
TEMPLATES="$HOME/.local/share/godot/export_templates/${VERSION%%.official*}"
if [ ! -f "$TEMPLATES/android_debug.apk" ]; then
	echo "android.sh: export templates for ${VERSION%%.official*} are missing." >&2
	echo "  install them from the editor (Editor > Manage Export Templates)," >&2
	echo "  or unpack the .tpz release into $TEMPLATES" >&2
	exit 1
fi

#---------------------------------------------------------------------- rebuild
echo "==> exporting $PRESET with $VERSION"
rm -f "$APK"
"$GODOT" --headless --path "$HERE" --export-debug "$PRESET" "$APK" 2>&1 \
	| grep -viE '^ADDING|^\[ *[0-9]+%|^\[ DONE|kotlin|DebugProbes|^Godot Engine|^\s*$'
#the exporter is not reliable about its exit code, so check the file itself
[ -s "$APK" ] || die "export produced no APK"
echo "==> built $(basename "$APK") ($(du -h "$APK" | cut -f1))"

#---------------------------------------------------------------------- devices
if ! adb start-server >/dev/null 2>&1; then
	echo "android.sh: adb daemon will not start." >&2
	echo "  usually the inotify limit: sudo sysctl fs.inotify.max_user_instances=1024" >&2
	exit 1
fi

TARGETS=()
SEEN=""
while read -r id state _; do
	[ -z "${id:-}" ] && continue
	if [ "$state" != "device" ]; then
		echo "    skipping $id ($state)"
		continue
	fi
	#the same phone shows up twice when it is on USB and wifi at once
	serial="$(adb -s "$id" shell getprop ro.serialno 2>/dev/null | tr -d '\r\n')"
	case " $SEEN " in
		*" $serial "*) echo "    skipping $id (same phone as an earlier entry)"; continue ;;
	esac
	SEEN="$SEEN $serial"
	TARGETS+=("$id")
done < <(adb devices | tail -n +2)

[ ${#TARGETS[@]} -gt 0 ] || die "no phone connected (adb devices is empty)"

#---------------------------------------------------------------------- install
FAILED=0
for id in "${TARGETS[@]}"; do
	model="$(adb -s "$id" shell getprop ro.product.model 2>/dev/null | tr -d '\r\n')"
	echo "==> installing on $id ($model)"
	#adb tries an incremental install first and noisily falls back, that is fine
	if adb -s "$id" install -r "$APK" 2>&1 \
		| grep -viE '^\s+at |Exception occurred|Incremental|^Serving|^Performing|^All files' \
		| grep -q '^Success'; then
		echo "    installed"
		if [ "$LAUNCH" = 1 ]; then
			adb -s "$id" shell monkey -p "$PACKAGE" -c android.intent.category.LAUNCHER 1 >/dev/null 2>&1
			echo "    launched"
		fi
	else
		echo "    FAILED on $id" >&2
		FAILED=1
	fi
done

exit $FAILED
