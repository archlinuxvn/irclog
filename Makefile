_RD_TUXFAMILY = kyanh@ssh.tuxfamily.org:~/archlinuxvn/archlinuxvn.tuxfamily.org-web/htdocs/irclogs/
_RF_BOT_LOG   = "goodtrans.hcm:~/irclogs/freenode/\#archlinuxvn.log"

default:                             # list all section of this Makefile
	@cat Makefile | grep -E "^[a-z]+.*:"

tiny:                             # upload logs files to icy.homenet.org
	@echo ":: Uploading files to icy.homenet.org"
	@rsync -rapvessh --delete ./www/irclogs/ \
		tiny.icy.bar:/mnt/www/archlinuxvn/irclogs/

www/irclogs/.htpasswd: htpasswd   # create file for basic authentication
	@./make-htpasswd.sh > $(@)

tuxfamily:                         # upload web logs to tuxfamily server
	@echo ":: Uploading log files to tuxfamily"
	@rsync -rapve 'ssh -i /home/pi/.ssh/tux2' \
		--delete ./www/irclogs/ $(_RD_TUXFAMILY)

tidylog:                       # convert raw logs file into the web form
	@./log-tidy.sh

archives/archlinuxvn.log.gz::               # download raw logs from bot
	@echo ":: Download the files from remote and compress it"
	@cd archives \
		&& gunzip archlinuxvn.log.gz \
		&& rsync -rapv $(_RF_BOT_LOG) ./archlinuxvn.log
	@cd ./archives && gzip archlinuxvn.log

log-split: archives/archlinuxvn.log.gz
	@echo ":: Get the log for yesterday"
	@zcat archives/archlinuxvn.log.gz | ./irssi-log-split.sh

daily: archives/archlinuxvn.log.gz log-split tidylog tuxfamily tiny
