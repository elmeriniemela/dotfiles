#!/bin/bash
rsync -avz elmeri.asuscomm.com:.config/syncthing/ .config/syncthing
rsync -avz elmeri.asuscomm.com:.mozilla/ .mozilla
rsync -avz elmeri.asuscomm.com:.thunderbird/ .thunderbird
rsync -avz elmeri.asuscomm.com:School/ School
rsync -avz elmeri.asuscomm.com:Projects/ Projects
rsync -avz elmeri.asuscomm.com:Videos/ Videos
rsync -avz elmeri.asuscomm.com:Documents/ Documents

rsync -avz elmeri.asuscomm.com:*.ovpn .
rsync -avz elmeri.asuscomm.com:.bash_eternal_history .
rsync -avz elmeri.asuscomm.com:.psql_history .
rsync -avz elmeri.asuscomm.com:.python_history .
