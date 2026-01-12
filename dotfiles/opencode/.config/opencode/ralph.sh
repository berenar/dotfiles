#!/bin/bash
set -e

usage() {
	echo "Usage: $0 <iterations> <model>"
	echo "Example: $0 10 github-copilot/claude-sonnet-4"
	echo ""
	echo "Available models: opencode models"
	exit 1
}

if [ -z "$1" ] || [ -z "$2" ]; then
	usage
fi

ITERATIONS=$1
MODEL=$2
PRD_FILE="${PRD_FILE:-PRD.md}"
PROGRESS_FILE="${PROGRESS_FILE:-progress.md}"

if ! opencode models | grep -q "^$MODEL$"; then
	echo "Error: Model '$MODEL' not found."
	echo "Run 'opencode models' to see available models."
	exit 1
fi

if [ ! -f "$PRD_FILE" ]; then
	echo "Error: $PRD_FILE not found. Create it first."
	exit 1
fi

touch "$PROGRESS_FILE"

for ((i = 1; i <= $ITERATIONS; i++)); do
	echo "=== Ralph iteration $i of $ITERATIONS ==="

	result=$(OPENCODE_PERMISSION='{"*":"allow"}' opencode run \
		--model "$MODEL" \
		--file "$PRD_FILE" \
		--file "$PROGRESS_FILE" \
		-- \
		"1. Read the PRD and progress file.
2. Find the next incomplete task and implement it.
3. Run tests if applicable.
4. Update $PROGRESS_FILE with what you did.
5. Commit your changes using conventional commits.
   NEVER commit PRD.md, progress.md, or ralph.sh - only commit actual code changes.
ONLY DO ONE TASK AT A TIME.
If all tasks are complete, output <ralph>COMPLETE</ralph>.")

	echo "$result"

	if [[ "$result" == *"<ralph>COMPLETE</ralph>"* ]]; then
		echo "PRD complete after $i iterations."
		exit 0
	fi
done

echo "Completed $ITERATIONS iterations."
