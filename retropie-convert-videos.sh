#!/usr/bin/env bash

# Convert videos for RetroPie.
# A tool for RetroPie to convert videos.
#
# Requirements:
# - Retropie 4.x.x
# - libav-tools package

home="$(find /home -type d -name RetroPie -print -quit 2>/dev/null)"
home="${home%/RetroPie}"

readonly SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly ROMS_DIR="$home/RetroPie/roms"

function usage() {
    echo
    echo "USAGE: sudo $0 [options]"
    echo
    echo "Use '--help' to see all the options."
    echo
}

function is_retropie() {
    [[ -d "$home/RetroPie" && -d "$home/.emulationstation" && -d "/opt/retropie" ]]
}

function check_dependencies() {
    if ! which avconv > /dev/null; then
        echo "ERROR: The libav-tools package is not installed!" >&2
        echo "Please, install it with 'sudo apt-get install libav-tools'." >&2
        exit 1
    fi
}

function check_argument() {
    # XXX: this method doesn't accept arguments starting with '-'.
    if [[ -z "$2" || "$2" =~ ^- ]]; then
        echo >&2
        echo "ERROR: \"$1\" is missing an argument." >&2
        echo >&2
        echo "Try \"sudo $0 --help\" for more info." >&2
        echo >&2

        return 1
    fi
}

function get_options() {
    if [[ -z "$1" ]]; then
        usage

        exit 0
    fi

    while [[ -n "$1" ]]; do
        case "$1" in
#H -h, --help                                   Print the help message and exit.
            -h|--help)
                echo
                echo "Convert videos for RetroPie."
                echo "A tool for RetroPie to convert videos."
                echo
                echo "USAGE: sudo $0 [options]"
                echo
                echo "OPTIONS:"
                echo
                sed '/^#H /!d; s/^#H //' "$0"
                echo

                exit 0
                ;;

#H -c, --convert [color encoding system]     Convert videos to a speficic color ecoding system.
            -c|--convert)
                check_argument "$1" "$2" || exit 1
                shift
                for rom_dir in "$ROMS_DIR"/*; do
                    if [[ ! -L "$rom_dir" ]]; then
                        if [[ -d "$rom_dir/images" ]]; then
                            for video in "$rom_dir/images"/*-video.mp4; do
                                mkdir -p "$rom_dir/images/converted"
                                avconv -i "$video" -y -pix_fmt "$1" -strict experimental "$rom_dir/images/converted/$(basename "$video")" && echo "$(basename "$video") successfully converted!"
                            done
                        fi
                    fi
                done
                ;;
            *)
                echo "ERROR: invalid option \"$1\"" >&2
                exit 2
                ;;
        esac
        shift
    done
}

function main() {
    check_dependencies

    if ! is_retropie; then
        echo "ERROR: RetroPie is not installed. Aborting ..." >&2
        exit 1
    fi

    get_options "$@"
}

main "$@"