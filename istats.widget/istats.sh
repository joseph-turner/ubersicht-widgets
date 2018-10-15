#!/usr/bin/env bash

#
# Execute bash profile
#
PATH=$PATH:/usr/local/bin

# Execute iStats command
#
if [ -n "$(which istats)" ]; then
    # define command
    command=( "$(which istats)" )

    # execute
    "${command[@]}"
fi
