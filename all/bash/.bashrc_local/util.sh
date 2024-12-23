#!/bin/bash
###########################################################################
 # Name: util.sh
 # Author: Adam Camilli <AdamOCamilli@github.com>
 # Description: Useful snippets for rc dev from me + others
 # Date: 02/09/2024
###########################################################################

# From https://stackoverflow.com/a/4024263
# Compare version numbers
util_verlte() {
    printf '%s\n' "$1" "$2" | sort -C -V
}

util_verlt() {
    ! util_verlte "$2" "$1"
}

util_ver_between() {
    # args: min, actual, max
    printf '%s\n' "$@" | sort -C -V
}
