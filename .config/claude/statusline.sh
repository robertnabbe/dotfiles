#!/bin/bash
input=$(cat)

RED='\033[31m';
BOLD_RED='\033[1;31m';
GREEN='\033[32m';
YELLOW='\033[33m';
BLUE='\033[34m';
CYAN='\033[36m';

BLINK='\033[5m';

RESET='\033[0m'

# vars
MODEL_ID=$(echo "$input" | jq -r '.model.id')
SESSION_NAME=$(echo "$input" | jq -r '.session_name // ""')
BRANCH=""
git rev-parse --git-dir > /dev/null 2>&1 && BRANCH="$(git branch --show-current 2>/dev/null)"

TOTAL_COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
COST_FORMATTED=$(printf '$%.2f' "$TOTAL_COST")

DURATION_MS=$(echo "$input" | jq -r '.cost.total_duration_ms // 0')
TIME_MINS=$((DURATION_MS / 60000));
TIME_SECS=$(((DURATION_MS % 60000) / 1000))

RATE_LIMIT_PERCENTAGE_5HR=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // 0')
RATE_LIMIT_PERCENTAGE_5HR_TRUNCATED=${RATE_LIMIT_PERCENTAGE_5HR%.*}
RATE_LIMIT_5HR_RESET_EPOCH=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at')
RATE_LIMIT_5HR_RESET_TIME=$(date -r "$RATE_LIMIT_5HR_RESET_EPOCH")

# vim mode (if we have it)
VIM_MODE=$(echo "$input" | jq -r '.vim.mode' // "")
if [ "$VIM_MODE" != "" ]; then VIM="${CYAN}[${VIM_MODE}]${RESET} | ";
else VIM=""; fi

# change color of context usage percentage based on percentage
USED_PERCENTAGE=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
if [ "$USED_PERCENTAGE" -ge 85 ]; then CTX_COLOR="$RED"
elif [ "$USED_PERCENTAGE" -ge 60 ]; then CTX_COLOR="$YELLOW"
else CTX_COLOR="$GREEN"; fi

# change color of 5 hour rate limit usage percentage based on percentage
if [ "$RATE_LIMIT_PERCENTAGE_5HR_TRUNCATED" -ge 85 ]; then RATE_LIMIT_5HR_COLOR="$RED"
elif [ "$RATE_LIMIT_PERCENTAGE_5HR_TRUNCATED" -ge 60 ]; then RATE_LIMIT_5HR_COLOR="$YELLOW"
else RATE_LIMIT_5HR_COLOR="$GREEN"; fi

# tokens exceeded warning
EXCEEDS_200K_TOKENS=$(echo "$input" | jq -r '.exceeds_200k_tokens // false')
if [ "$EXCEEDS_200K_TOKENS" = true ]; then WARNING=" | ${BLINK}⚠️ 200k exceeded!${RESET}";
else WARNING=""; fi


echo -e "${BLUE}[$MODEL_ID]${RESET}: ${BOLD_RED}${BRANCH}${RESET}"
# if session name is not empty, print it
if [ "$SESSION_NAME" != "" ]; then
  echo -e "Session: ${CYAN}${SESSION_NAME}${RESET}"
else
  echo -e "Session: ${RED}UNNAMED SESSION${RESET}"
fi
echo -e "${VIM}ctx: ${CTX_COLOR}${USED_PERCENTAGE}%${RESET}${WARNING} / ${COST_FORMATTED} | ${TIME_MINS}m ${TIME_SECS}s | (${RATE_LIMIT_5HR_COLOR}${RATE_LIMIT_PERCENTAGE_5HR_TRUNCATED}%${RESET} resets: ${RATE_LIMIT_5HR_RESET_TIME})"
echo -e "--------------------------------"
