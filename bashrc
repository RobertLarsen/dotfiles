#!/bin/bash

export PAGER=less
export EDITOR=vim
export PATH=$PATH:$HOME/.bin:$HOME/code/pwntools/bin
export PYTHONPATH=$PYTHONPATH:$HOME/code/pwntools
export PS1="\$(fancyprompt) $ ";
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
alias PS1="export PS1='$ '"
alias msfconsole="docker run --rm -it robertlarsen/metasploit msfconsole"
alias msfvenom="docker run --rm -it robertlarsen/metasploit msfvenom"
alias d=./dev
alias www='python -m SimpleHTTPServer'

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
#!/usr/bin/env python3
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

    test -d src || mkdir src

    if test -f "src/${fname}"; then
        echo "${fname} already exists."
        false
    else
        cat >"src/${fname}"<<EOF
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

        if ! test -f CMakeLists.txt; then
            cat >CMakeLists.txt<<EOF
cmake_minimum_required(VERSION 3.5)
project(${fname%.c})

set(CMAKE_C_FLAGS "-ggdb")
add_executable(${fname%.c} src/${fname})
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
		nvim "src/${fname}"
    fi
}

function kernmod(){
    if [[ "${1}" == "" ]]; then
        fname=$(basename $(pwd) | tr A-Z a-z)
    else
        fname="${1}"
    fi
    
    test -f ${fname}.c || cat >"${fname}.c"<<EOF
#include <linux/module.h>
#include <linux/init.h>
#include <linux/list.h>    /* Linked list structures and functions */
#include <linux/slab.h>    /* kmalloc, kfree */
#include <linux/sched.h>   /* task_struct */
#include <linux/uaccess.h> /* copy_(to,from)_user */
#include <linux/cdev.h>    /* character device */
#include <linux/fs.h>      /* file_operations */

static int __init my_init(void)
{
    pr_info(KBUILD_MODNAME " loaded at %p\n", my_init);
    return 0;
}

static void __exit my_free(void)
{
    pr_info(KBUILD_MODNAME " unloaded at %p\n", my_free);
}

module_init(my_init);
module_exit(my_free);

MODULE_AUTHOR("Robert Larsen <robert@the-playground.dk>");
MODULE_LICENSE("GPL v2");
EOF
    test -f Makefile || cat >Makefile<<EOF
KDIR = /lib/modules/\`uname -r\`/build

kbuild:
	make -C \$(KDIR) M=\`pwd\`

clean:
	make -C \$(KDIR) M=\`pwd\` clean
EOF
    test -f Kbuild || cat >Kbuild<<EOF
EXTRA_FLAGS = -Wall -g
obj-m       = ${fname}.o
EOF
    test -e kernel || ln -s /lib/modules/$(uname -r)/build/ kernel
    vim ${fname}.c
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
    find "${ROOT}" -executable | while read path; do
        if readelf -h "${path}" >/dev/null 2>&1; then
            echo "${path}"
        fi
    done
}
