#!/usr/bin/env bash

shopt -s extglob
set -o errtrace
set -o errexit

log()  { printf "$*\n" ; return $? ;  }

fail() { log "\nERROR: $*\n" ; exit 1 ; }

usage()
{
  printf "

Usage

  #actions

Options

  #options
  
Actions

  help - Display CLI help (this output)

"
}
