#!/bin/bash

export PAGER=less
export EDITOR=vim
export PATH=$PATH:$HOME/.bin:$HOME/code/pwntools/bin
export PYTHONPATH=$PYTHONPATH:$HOME/code/pwntools
export PS1="\$(fancyprompt_smiley)\$(fancyprompt_git)\$(fancyprompt_basedir) $ ";
export VAGRANT_DEFAULT_PROVIDER=vmware_workstation
export TERM=xterm-256color
export DEBFULLNAME="Robert Larsen"
export DEBEMAIL="robert@the-playground.dk"
export GOPATH=~/code/Go

CLEAR_LINE="\e[2K\r";
BG_COLOR_WHITE="\e[107m";
BG_COLOR_YELLOW="\e[43m";
BG_COLOR_GREEN="\e[42m";
COLOR_BLACK="\e[30m";
COLOR_GREEN="\e[32m";
COLOR_YELLOW="\e[33m";
COLOR_CYAN="\e[36m";
COLOR_RED="\e[31m";
COLOR_WHITE="\e[97m";
COLOR_RESET="\e[0m";

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
complete -F _quilt_completion $_quilt_complete_opt dquilt

function fancyprompt_smiley(){
    if [ $? == 0 ]; then
        echo -e "${BG_COLOR_WHITE}${COLOR_GREEN}\u263a ${COLOR_RESET}";
    else
        echo -e "${BG_COLOR_WHITE}${COLOR_RED}\u2639 ${COLOR_RESET}";
    fi
};

function fancyprompt_basedir(){
    echo -e "${BG_COLOR_GREEN}${COLOR_WHITE} /$(basename $(pwd))/ ${COLOR_RESET}";
};

function fancyprompt_git(){
    if git status >/dev/null 2>&1; then
        if test "$(git status --porcelain)" == ""; then
            echo -en "\e[48;5;021m";
        else
            echo -en "\e[48;5;162m";
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

    gpg -o - "$ENCRYPTEDFILE" > $TEMPFILE1
    if [ "$?" != "0" ]; then
        return
    fi
    cp $TEMPFILE1 $TEMPFILE2

    vim $TEMPFILE1
    diff $TEMPFILE1 $TEMPFILE2 >/dev/null 2>&1
    if [ "$?" != "0" ]; then
        CODE=1
        while [ "$CODE" != "0" ]; do
            gpg -o - --symmetric $TEMPFILE1 > "$ENCRYPTEDFILE"
            CODE=$?
        done
    fi
    wipe -fs $TEMPFILE1 $TEMPFILE2
}

VimPasswords(){
    file="$HOME/.passwords.txt.gpg"
    OpenEncrypted "$file"
}

Password(){
    if ! test -f "${file}"; then
        file="$HOME/.passwords.txt.gpg"
    fi
    gpg < "$file" | grep -i $1
}

function home(){
    ssh -p 2200 robert@home.the-playground.dk
}

function trampolines(){
    ROPgadget --binary ${1} | grep -E ': ((call)|(jmp)) (e|r)'
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

from pwn import *

context(arch = 'i386', os = 'linux')

SHELLCODE = asm(shellcraft.findpeersh())

EOF
        chmod +x "${fname}"
        vim "${fname}"
    fi
}

function c(){
    if [[ "${1}" == "" ]]; then
        fname=$(basename $(pwd) | tr A-Z a-z).c
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
		vim "${fname}"
    fi
}

function vadush(){
   vagrant destroy -f $* && vagrant up $* && vagrant ssh $1
}

function vadu(){
   vagrant destroy -f $* && vagrant up $*
}
