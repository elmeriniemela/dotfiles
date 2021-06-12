#!/bin/bash
rsync -avz --delete .config/syncthing/ elmeri.asuscomm.com:.config/syncthing
rsync -avz --delete .mozilla/ elmeri.asuscomm.com:.mozilla
rsync -avz --delete .thunderbird/ elmeri.asuscomm.com:.thunderbird
rsync -avz --delete School/ elmeri.asuscomm.com:School
rsync -avz --delete Projects/ elmeri.asuscomm.com:Projects
rsync -avz --delete Videos/ elmeri.asuscomm.com:Videos
rsync -avz --delete Documents/ elmeri.asuscomm.com:Documents
rsync -avz --delete Work/ elmeri.asuscomm.com:Work

rsync -avz --delete *.ovpn elmeri.asuscomm.com:
rsync -avz --delete .bash_eternal_history elmeri.asuscomm.com:
rsync -avz --delete .psql_history elmeri.asuscomm.com:
rsync -avz --delete .python_history  elmeri.asuscomm.com:
