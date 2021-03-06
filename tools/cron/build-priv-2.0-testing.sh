#!/bin/sh

# disable autorun from cron
#[ -z "$1" ] && exit

# Обновляет репозиторий и выкладывает новую сборку в случае необходимости

. $(dirname $0)/build-funcs.sh
. $(dirname $0)/build-funcs-priv.sh

TEMPREPODIR=/srv/$USER/Projects/autobuild/wine-priv
REPO=git.office:/projects/wine/wine-etersoft.git
REPOALIAS=origin
WORKBRANCH=eter-2.0.0
WORKTARGET=2.0-testing
SUBSPEC="local sql network cad"

jump_to_repo

pull_changes || exit

priv_update_changelog

priv_pub_and_push
