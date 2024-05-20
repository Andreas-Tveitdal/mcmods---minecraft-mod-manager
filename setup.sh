#!/bin/bash

DIRECTORY="$(dirname ${BASH_SOURCE[0]})"
MCMODSDIRECTORY=~/.minecraft-mods

mcmods-help() {
    helpTopic="$1"
    if [ "${helpTopic}" = "" ]; then
        helpTopic="overview"
    fi
    echo "$(< ${DIRECTORY}/help-${helpTopic}.txt)"
    return 0
}
mcmods-compare() {
    if [ "$1" = "" ] || [ "$2" = "" ]; then
        mcmods-help "compare"
        return 0
    fi
    if [ ! -d "${MCMODSDIRECTORY}/$1" ]; then
        echo "Error: version $1 doesn't exist"
        return 1
    fi
    if [ ! -d "${MCMODSDIRECTORY}/$2" ]; then
        echo "Error: version $2 doesn't exist"
        return 1
    fi
    if [ "$1" = "$2" ]; then
        echo "Error: cannot compare version $1 with itself"
        return 1
    fi
    declare -i v1mods=0
    declare -i v2mods=0
    declare -i identicalMods=0
    local firstRun="true"
    for v1mod in ${MCMODSDIRECTORY}/$1/*; do
        local v1modName=$(basename "${v1mod}")
        if [ ! "${v1modName}" = "*" ]; then
            v1mods=${v1mods}+1
        fi
        local identicalMod="false"
        for v2mod in ${MCMODSDIRECTORY}/$2/*; do
            local v2modName=$(basename "${v2mod}")
            if [ ! "${v2modName}" = "*" ]; then
                if [ "${firstRun}" = "true" ]; then
                    v2mods=${v2mods}+1
                fi
                if [ ! "${v1modName}" = "*" ]; then
                    if [ "${v1modName}" = "${v2modName}" ]; then
                        identicalMod="true"
                    fi
                fi
            fi
        done
        if [ "${identicalMod}" = "true" ]; then
            identicalMods=${identicalMods}+1
        fi
        firstRun="false"
    done
    local v1differentMods=$((${v1mods}-${identicalMods}))
    local v2differentMods=$((${v2mods}-${identicalMods}))
    echo "version $1 has ${v1mods} mods"
    echo "version $2 has ${v2mods} mods"
    echo "${identicalMods} identical mods"
    echo "version $1 has ${v1differentMods} unique mods"
    echo "version $2 has ${v2differentMods} unique mods"
    return 0
}
mcmods-list() {
    local output=$(ls "${MCMODSDIRECTORY}")
    if [ "${output}" = "" ]; then
        echo "no versions saved"
        return 0
    fi
    echo "${output}"
    return 0
}
mcmods-load() {
    if [ "$1" = "" ]; then
        echo "Versions:"
        mcmods-list
        return 0
    fi
    if [ ! -d "${MCMODSDIRECTORY}/$1" ]; then
        echo "Error: version $1 doesn't exist"
        return 1
    fi
    ln -sfn ${MCMODSDIRECTORY}/$1/ ~/.minecraft/mods
    echo "loaded version $1"
    return 0
}
mcmods-mods() {
    if [ ! -d "${MCMODSDIRECTORY}/$1" ]; then
        echo "Error: version $1 doesn't exist"
        return 1
    fi
    if [ "$1" = "" ]; then
        local currentVersion="$(basename $(realpath ~/.minecraft/mods))"
        local versionName="${currentVersion}"
    fi
    if [ ! "$1" = "" ]; then
        local versionName="$1"
    fi
    for mod in ${MCMODSDIRECTORY}/${versionName}/*; do
        local modName=$(basename "${mod}")
        if [ "${modName}" = "*" ]; then
            echo "no mods in version $1"
            break
        fi
        echo "${modName}"
    done
    return 0
}
mcmods-new() {
    if [ "$1" = "" ]; then
        mcmods-help "new"
        return 0
    fi
    if [ -d "${MCMODSDIRECTORY}/$1" ]; then
        echo "Error: version $1 already exists"
        return 1
    fi
    mkdir "${MCMODSDIRECTORY}/$1"
    mcmods-load "$1"
    echo "created version $1"
    return 0
}
mcmods-remove() {
    if [ "$1" = "" ]; then
        mcmods-help "remove"
        return 0
    fi
    if [ ! -d "${MCMODSDIRECTORY}/$1" ]; then
        echo "Error: version $1 doesn't exist"
        return 1
    fi
    rm -rf "${MCMODSDIRECTORY}/$1"
    echo "removed version $1"
    return 0
}
mcmods-rename() {
    if [ "$1" = "" ] || [ "$2" = "" ]; then
        mcmods-help "rename"
        return 0
    fi
    if [ ! -d "${MCMODSDIRECTORY}/$1" ]; then
        echo "Error: version $1 doesn't exist"
        return 1
    fi
    mv "${MCMODSDIRECTORY}/$1" "${MCMODSDIRECTORY}/$2"
    echo "renamed version $1 to version $2"
    return 0
}
mcmods-save() {
    if [ "$1" = "" ]; then
        mcmods-help "save"
        return 0
    fi
    if [ -d "${MCMODSDIRECTORY}/$1" ]; then
        echo "Error: version $1 already exists"
        return 1
    fi
    cp -r ~/.minecraft/mods ${MCMODSDIRECTORY}/${1}
    echo "saved version $1"
    return 0
}
mcmods-status() {
    local currentVersion="$(basename $(realpath ~/.minecraft/mods))"
    echo "INFO"
    echo "currently on version ${currentVersion}"
    mcmods-mods
    if [ "$1" = "" ]; then
        return 0
    fi
    echo ""
    echo "COMPARISON"
    mcmods-compare "${currentVersion}" "$1"
    return 0
}

mcmods() {
    local subcommand=$1
    shift 1
    if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        mcmods-help "${subcommand}" "$@"
        return 0
    fi
    if [ "${subcommand}" = "" ] || [ "$subcommand" = "help" ]; then
        mcmods-help "$@"
        return 0
    fi
    if [ "${subcommand}" = "compare" ]; then
        mcmods-compare "$@"
        return 0
    fi
    if [ "${subcommand}" = "list" ]; then
        mcmods-list "$@"
        return 0
    fi
    if [ "${subcommand}" = "load" ]; then
        mcmods-load "$@"
        return 0
    fi
    if [ "${subcommand}" = "mods" ]; then
        mcmods-mods "$@"
        return 0
    fi
    if [ "${subcommand}" = "new" ]; then
        mcmods-new "$@"
        return 0
    fi
    if [ "${subcommand}" = "remove" ]; then
        mcmods-remove "$@"
        return 0
    fi
    if [ "${subcommand}" = "rename" ]; then
        mcmods-rename "$@"
        return 0
    fi
    if [ "${subcommand}" = "save" ]; then
        mcmods-save "$@"
        return 0
    fi
    if [ "${subcommand}" = "status" ]; then
        mcmods-status "$@"
        return 0
    fi
    echo "Error: unknown subcommand ${subcommand}"
    return 1
}

