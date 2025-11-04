progress_bar() {
    local task="$1"
    local duration="${2:-2}"
    local width=40
    local char="█"

    local YELLOW=$'\033[1;33m'
    local GREEN=$'\033[1;32m'
    local RESET=$'\033[0m'

    local term_width=$(tput cols)

    for i in $(seq 0 100); do
        local step=$((i * width / 100))
        local bar=$(printf "%0.s$char" $(seq 1 $step))
        local space=$(printf "%0.s " $(seq 1 $((width - step))))
        local color="$YELLOW"
        (( i == 100 )) && color="$GREEN"

        local prog_text="[$bar$space] $i%"
        local pad=$((term_width - ${#task} - ${#prog_text} - 5))
        ((pad<0)) && pad=0
        local padding=$(printf "%*s" "$pad" "")

        printf "\r[*] %s%s%s%s" "$task" "$padding" "$color" "$prog_text$RESET"

        sleep "$(awk "BEGIN {print $duration/100}")"
    done
    echo
}