#!/bin/bash

export PAGER=less
export EDITOR=vim
export PATH=$PATH:$HOME/.bin:$HOME/code/pwntools/bin
export PYTHONPATH=$PYTHONPATH:$HOME/code/pwntools
export PS1="\$(fancyprompt) $ ";
export VAGRANT_DEFAULT_PROVIDER=vmware_workstation
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

function tput_colors(){
    echo "tput setaf <number>"
    for i in {0..255}; do if ! test 0 -eq $i && test 0 -eq $((i%16)); then echo; fi; printf $(tput setaf $i)"%03d " $i; done; echo
    echo "tput setab <number>"
    for i in {0..255}; do if ! test 0 -eq $i && test 0 -eq $((i%16)); then echo; fi; printf $(tput setab $i)"%03d " $i; done; echo
}

alias dkpg=dpkg
alias mdkir=mkdir
alias sl=ls
alias ci='git commit'
alias st='git status'
alias log='git log'
alias revert='svn revert'
alias slack="/opt/google/chrome/google-chrome --app=https://cego.slack.com/messages/general/"
alias PS1="export PS1='$ '"
alias dquilt="quilt --quiltrc=${HOME}/.bin/quiltrc-dpkg"
alias msfconsole="docker run --rm -it robertlarsen/metasploit msfconsole"
alias msfvenom="docker run --rm -it robertlarsen/metasploit msfvenom"
alias d=./dev
alias irssi="docker run -it --rm -v /etc/localtime:/etc/localtime:ro -v $HOME/.irssi:/home/user/.irssi:ro --read-only --name irssi -e TERM -u $(id -u):$(id -g) irssi"
complete -F _quilt_completion $_quilt_complete_opt dquilt

function fancyprompt(){
    echo -en "$(fancyprompt_smiley)$(fancyprompt_git)$(fancyprompt_basedir)"
}

function fancyprompt_smiley(){
    if [ $? == 0 ]; then
        echo -e "${BG_COLOR_WHITE}${COLOR_GREEN}\u263a ${COLOR_RESET}";
    else
        echo -e "${BG_COLOR_WHITE}${COLOR_RED}\u2639 ${COLOR_RESET}";
    fi
};

function fancyprompt_basedir(){
    echo -e "${BG_COLOR_GREEN}${COLOR_WHITE} /$(basename "$(pwd)")/ ${COLOR_RESET}";
};

function fancyprompt_git(){
    if git status >/dev/null 2>&1; then
        if test "$(git status --porcelain | grep -Ev '^\?\?')" == ""; then
            echo -en "\001\e[48;5;021m\002";
        else
            echo -en "\001\e[48;5;162m\002";
        fi;
        echo -e "${COLOR_WHITE} $(git rev-parse --abbrev-ref HEAD 2>/dev/null) ${COLOR_RESET}";
    fi
};

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

    gpg -o - "${ENCRYPTEDFILE}" > "${TEMPFILE1}"
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
    gpg < "$file" | grep -i "${1}"
}

function home(){
    ssh -p 2200 robert@home.the-playground.dk
}

function trampolines(){
    ROPgadget --binary "${1}" | grep -E ': ((call)|(jmp)) (e|r)'
}

function pwn(){
    if [[ "${1}" == "" ]]; then
        fname=exploit.py
    else
        fname="${1}"
    fi
    if test -f "${fname}"; then
        echo "${fname} already exists."
        false
    else
        cat > "${fname}"<<EOF
#!/usr/bin/env python2
# -*- coding: utf-8 -*-

from pwn import context, asm, shellcraft, remote, process, flat, fit

context(arch='i386', os='linux')

SHELLCODE = asm(shellcraft.findpeersh())

EOF
        chmod +x "${fname}"
        nvim "${fname}"
    fi
}

function c(){
    if [[ "${1}" == "" ]]; then
        fname=$(basename "$(pwd)" | tr '[:upper:]' '[:lower:]').c
    else
        fname="${1}"
    fi

    if test -f "${fname}"; then
        echo "${fname} already exists."
        false
    else
        cat >"${fname}"<<EOF
#include <stdio.h>

int main(int argc __attribute__((unused)), char ** argv __attribute__((unused))) {
    return 0;
}
EOF
        if ! test -f .ycm_extra_conf.py; then
            cat >.ycm_extra_conf.py<<EOF
def FlagsForFile(f):
    return {
        'flags' : ['-Wall', '-Wextra'],
        'do_cache' : True
    }
EOF
        fi
        if ! test -f Makefile; then
            cat >Makefile<<EOF
CFLAGS=-Wall -Wextra -ggdb
.phony: run clean all

all: ${fname%.c}

${fname%.c}: ${fname}

clean:
	rm -f ${fname%.c}

run: ${fname%.c}
	./${fname%.c}
EOF
        fi
        if ! test -f .gitignore; then
            cat >.gitignore<<EOF
**/*.o
**/.*.swp
${fname%.c}
core
EOF
        fi
		nvim "${fname}"
    fi
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
            --exclude "Browsers" \
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
            --exclude "VirtualBox VMs" \
            --exclude "vmware" \
            --exclude ".vagrant" \
            --exclude ".vim" \
            --exclude "pwnadventure" \
            --exclude "Android" \
            --exclude ".android" \
            --exclude ".gradle" \
            --exclude ".AndroidStudio3.1" \
            --exclude "buildroot-2018.02.2" \
            --exclude "Browser" \
            --exclude "Videos" \
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
