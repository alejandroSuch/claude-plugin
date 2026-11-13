---
description: Move this session into Kepler (requires Kepler)
allowed-tools: Bash(${CLAUDE_PLUGIN_ROOT}/scripts/open-in-kepler.sh:*)
---
!`"${CLAUDE_PLUGIN_ROOT}/scripts/open-in-kepler.sh" ${CLAUDE_SESSION_ID}`
If the line above says KEPLER_OPENED, reply only: "Moving this session to Kepler. This terminal will close."
If it says KEPLER_NOT_INSTALLED, reply only: "Kepler isn't installed. Download it at https://www.gitkraken.com/kepler"
Otherwise reply only: "Kepler could not be opened from this session." Do not run any tool.
