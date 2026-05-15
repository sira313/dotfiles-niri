#!/usr/bin/env bash
# Outputs indicator if wf-recorder is running
if pgrep -x wf-recorder > /dev/null; then
	echo '{"alt":"recording"}'
else
	echo '{"alt":"idle"}'
fi