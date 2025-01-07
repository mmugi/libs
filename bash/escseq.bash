lib_self='escseq.bash'

if [ -z "${BASH_VERSION:-}" ]; then
    echo "${lib_self}: error: This library must be sourced in Bash."
    return 1 2>/dev/null || exit 1
fi

if [[ -t 1 ]]; then
    _esc() { printf "\033[%sm" "$1"; }
else
    _esc() { :; }
fi

sgr() {
    usage() {
        echo 'USAGE: sgr [option]'
        echo 'DESCRIPTION:'
        echo '    Print the ANSI escape code SGR(Select Graphic Rendition) parameter.'
        echo 'OPTIONS:'
        echo '  - Reset:'
        echo '      Omitting the option will reset the color and attributes.'
        echo '  - Colors:'
        echo '      black'
        echo '      red'
        echo '      green'
        echo '      yellow'
        echo '      blue'
        echo '      magenta'
        echo '      cyan'
        echo '      white'
        echo '      default'
        echo '  - Attributes:'
        echo '      reset_attr'
        echo '      bold'
        echo '      faint'
        echo '      italic'
        echo '      underline'
        echo '      blink'
        echo '      fast_blink'
        echo '      reverse'
        echo '      conceal'
        echo '      strike'
    }

    # colors
    local -r black='30'
    local -r red='31'
    local -r green='32'
    local -r yellow='33'
    local -r blue='34'
    local -r magenta='35'
    local -r cyan='36'
    local -r white='37'
    local -r default='39'

    # attributes
    local -r reset_attr='0'
    local -r bold='1'
    local -r faint='2'
    local -r italic='3'
    local -r underline='4'
    local -r blink='5'
    local -r fast_blink='6'
    local -r reverse='7'
    local -r conceal='8'
    local -r strike='9'
    local -r reset_all="${reset_attr};${default}"

    if [[ $# -eq 0 ]]; then
        _esc "$reset_all"
        return 0
    fi

    local code_color
    local code_attr_arr=()
    while (($# > 0)); do
        case "$1" in
            # colors
            black)    code_color="$black";;
            red)      code_color="$red";;
            green)    code_color="$green";;
            yellow)   code_color="$yellow";;
            blue)     code_color="$blue";;
            magenta)  code_color="$magenta";;
            cyan)     code_color="$cyan";;
            white)    code_color="$white";;
            default)  code_color="$default";;
            [0-9]*)   code_color="38;5;$1";;
            # attributes
            reset_attr)  code_attr_arr+=("$reset_attr");;
            bold)        code_attr_arr+=("$bold");;
            italic)      code_attr_arr+=("$italic");;
            underline)   code_attr_arr+=("$underline");;
            blink)       code_attr_arr+=("$blink");;
            # others
            -h | --help)
                usage
                return 0;;
            *)
                echo "${FUNCNAME[0]}: illegal option: $1" >&2
                return 1;;
        esac
        shift
    done

    local -r code_attr_arr_len="${#code_attr_arr[@]}"
    if [[ $code_attr_arr_len -eq 0 ]]; then
        if [[ -z ${code_color:-} ]]; then
            echo "${FUNCNAME[0]}: option couldn't be detected" >&2
            return 1
        else
            printf '%s' "$(_esc "${code_color}")"
        fi
    else
        local -r code_attr=$(
            for attr in "${code_attr_arr[@]}"; do
                echo -n "${attr};"
            done)
        if [[ -z ${code_color:-} ]]; then
            printf '%s' "$(_esc "${code_attr%;}")"
        else
            printf '%s' "$(_esc "${code_attr}${code_color}")"
        fi
    fi
}
