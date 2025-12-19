#!bash

HOST=ftp.formally.fm
USER=9346531@aruba.it

if [ ! -d public ]; then
  hugo || exit
fi

lftp -c "
  set ftp:ssl-allow no &&
  set ftp:passive-mode yes &&
  open $HOST &&
  user $USER &&
  mirror -Rv public www.formally.fm"
