UPDATE USR$WG_HOURTYPE
  SET USR$WG_EXCLUDEFORSICKLIST = 1
WHERE
  USR$CODE IN ('цв','ця','цо','дн','лн','саг','п','с','ю','а','дон','ца','нф','ма','ц','н','дл','д','нюд','ба','ню')
