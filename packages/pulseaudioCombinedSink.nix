{
  pulseaudio,
  pipewire,
  writeShellScriptBin,
  ...
}:
writeShellScriptBin "pulseaudioCombinedSink" ''
  #!/usr/bin/env bash
  set -e

  # This script creates a combined sink for PulseAudio.
  # It monitors the available sinks and creates a new sink that combines them using pipewire.

  pactl="${pulseaudio}/bin/pactl"
  pw_link="${pipewire}/bin/pw-link"


  $pactl load-module module-null-sink media.class=Audio/Sink sink_name=all-stereo-sinks channel_map=stereo
  $pactl set-default-sink all-stereo-sinks

  # cleanup:
  function cleanup {
    for m in $($pactl list short modules | awk '/sink_name=all-stereo-sinks/ { print $1 }'); do
     $pactl unload-module "$m";
    done

    exit 0
  }
  trap cleanup EXIT

  while sleep 3; do
    for s in $($pw_link -i | awk 'match($0, /(.*):playback/, a) { print a[1] }' | sort -u); do
      $pw_link all-stereo-sinks "$s" 2>/dev/null;
    done;
  done
''
