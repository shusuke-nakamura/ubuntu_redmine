#!/bin/bash
RED_PW="redmine"
expect -c "
      spawn sudo -u postgres createuser -P redmine
      expect \"Enter password for new role:\"
      send -- \"${RED_PW}\n\"
      sleep 2
      expect \"Enter it again:\"
      send -- \"${RED_PW}\n\"
      sleep 2
      "