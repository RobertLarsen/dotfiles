#!/bin/bash

export PAGER=less
export EDITOR=vim
export PATH=$PATH:$HOME/.bin:$HOME/code/pwntools/bin
export PYTHONPATH=$PYTHONPATH:$HOME/code/pwntools
#export VAGRANT_DEFAULT_PROVIDER=vmware_workstation
export VAGRANT_DEFAULT_PROVIDER=virtualbox
export TERM=xterm-256color
export DEBFULLNAME="Robert Larsen"
export DEBEMAIL="robert@the-playground.dk"
export GOPATH=~/code/Go

CLEAR_LINE="\e[2K\r";
BG_COLOR_WHITE="\001$(tput setab 7)\002";
BG_COLOR_YELLOW="\001$(tput setab 226)\002";
BG_COLOR_GREEN="\001$(tput setab 2)\002";
COLOR_BLACK="\001$(tput setaf 16)\002";
COLOR_GREEN="\001$(tput setaf 2)\002";
COLOR_YELLOW="\001$(tput setaf 226)\002";
COLOR_CYAN="\001$(tput setaf 87)\002";
COLOR_RED="\001$(tput setaf 1)\002";
COLOR_WHITE="\001$(tput setaf 7)\002";
COLOR_RESET="\001$(tput sgr0)\002";

alias dkpg=dpkg
alias mdkir=mkdir
alias sl=ls
alias ci='git commit'
alias st='git status'
alias log='git log'
alias PS1="export PS1='$ '"
alias msfconsole="docker run --rm -it robertlarsen/metasploit msfconsole"
alias msfvenom="docker run --rm -it robertlarsen/metasploit msfvenom"
alias d=./dev
alias www='python -m SimpleHTTPServer'

complete -F _quilt_completion $_quilt_complete_opt dquilt

function print_status(){
    echo -ne "${CLEAR_LINE}${COLOR_YELLOW}${1}${COLOR_RESET}"
}

function print_success(){
    echo -e "${CLEAR_LINE}${COLOR_GREEN}${1}${COLOR_RESET}"
}

function print_failure(){
    echo -e "${CLEAR_LINE}${COLOR_RED}${1}${COLOR_RESET}"
}

OpenEncrypted(){
    ENCRYPTEDFILE="$1"

    if [ ! -f "$ENCRYPTEDFILE" ]; then
        echo "Ingen password fil"
        return
    fi

    TEMPFILE1=$(tempfile)
    TEMPFILE2=$(tempfile)

    gpg --decrypt -o - "${ENCRYPTEDFILE}" > "${TEMPFILE1}"
    if [ "$?" != "0" ]; then
        return
    fi
    cp "${TEMPFILE1}" "${TEMPFILE2}"

    vim "${TEMPFILE1}"
    diff "${TEMPFILE1}" "${TEMPFILE2}" >/dev/null 2>&1
    if [ "$?" != "0" ]; then
        CODE=1
        while [ "$CODE" != "0" ]; do
            gpg -o - --symmetric "${TEMPFILE1}" > "${ENCRYPTEDFILE}"
            CODE=$?
        done
    fi
    wipe -fs "${TEMPFILE1}" "${TEMPFILE2}"
}

VimPasswords(){
    file="$HOME/.passwords.txt.gpg"
    OpenEncrypted "$file"
}

Password(){
    if ! test -f "${file}"; then
        file="$HOME/.passwords.txt.gpg"
    fi
    gpg --decrypt < "$file" | grep -i "${1}"
}

function home(){
    ssh -p 2200 robert@home.the-playground.dk
}

function trampolines(){
    ROPgadget --binary "${1}" | grep -E ': ((call)|(jmp)) (e|r)'
}

function vadush(){
   vagrant destroy -f "$@" && vagrant up "$@" && vagrant ssh "$1"
}

function vadu(){
   vagrant destroy -f "$@" && vagrant up "$@"
}

function backup(){
    PATHS_TO_BACKUP=(
        $HOME
        /etc/fstab
        /etc/hosts
    )
    test -n "$BACKUP_DESTINATION" || BACKUP_DESTINATION=/media/bluedisk/Backup/$(hostname)

    backup_directory(){
        rsync -azv --copy-links --ignore-errors \
            --exclude ".repositories" \
            --exclude ".thumbnails" \
            --exclude ".config" \
            --exclude ".npm" \
            --exclude ".cache" \
            --exclude ".vagrant.d" \
            --exclude ".cache" \
            --exclude ".local" \
            --exclude ".Private" \
            --exclude ".VirtualBox" \
            --exclude ".wine" \
            --exclude ".gvfs" \
            --exclude ".steam" \
            --exclude ".vagrant" \
            --exclude ".vim" \
            --exclude ".android" \
            --exclude ".gradle" \
            --exclude ".cargo" \
            --exclude ".AndroidStudio3.1" \
            --exclude "no-backup" \
            --exclude "Android" \
            --exclude "Videos" \
            --exclude "VirtualBox VMs" \
            --exclude "vmware" \
            --no-g --no-o --delete --progress "$1" "$BACKUP_DESTINATION"
    }

    backup_file(){
        cp "$1" "$BACKUP_DESTINATION"
    }

    do_backup(){
        if [ -d "$1" ]; then
            backup_directory "$1"
        else
            backup_file "$1"
        fi
    }


    if test -d "$BACKUP_DESTINATION" >/dev/null; then
        date > "$BACKUP_DESTINATION/last_backup_time"

        for (( i=0; i<${#PATHS_TO_BACKUP[*]}; i=$((i+1)) )); do
            path=${PATHS_TO_BACKUP[$i]}
            do_backup "$path"
        done

        crontab -l > "$BACKUP_DESTINATION/crontab"
        dpkg --get-selections > "$BACKUP_DESTINATION/dpkg-selections"
        df -h > "$BACKUP_DESTINATION/df-h"
        DISPLAY=:0.0 scrot "$BACKUP_DESTINATION/screenshot.png"
        date >> "$BACKUP_DESTINATION/last_backup_time"
    fi
}

function run_qemu(){
    cd ~/code/linux-kernel-labs/tools/labs || return
    while true; do
        while ! test -f start_vm; do
            sleep 1
        done
        rm start_vm
        make boot
        killall minicom
    done
}

function run_minicom(){
    cd ~/code/linux-kernel-labs/tools/labs || return
    while true; do
        while ! test -e serial.pts; do
            clear
            echo "$(date) - Wait for VM"
            sleep 1
        done
        minicom -D serial.pts
    done
}

function find_elfs(){
    ROOT=${1:-/}
    find "${ROOT}" -executable 2>/dev/null | while read path; do
        if readelf -h "${path}" >/dev/null 2>&1; then
            echo "${path}"
        fi
    done
}
