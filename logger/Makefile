_RD_TUXFAMILY = kyanh@ssh.tuxfamily.org:~/archlinuxvn/archlinuxvn.tuxfamily.org-web/htdocs/irclogs/

ifndef _ARCHIVE
  _ARCHIVE    = archives/archlinuxvn.log.gz
endif

default:                             # list all section of this Makefile
	@cat Makefile | grep -E "^[a-z]+.*:"

www/irclogs/.htpasswd: htpasswd   # create file for basic authentication
	@./make-htpasswd.sh > $(@)

tuxfamily:                         # upload web logs to tuxfamily server
	@echo ":: Uploading log files to tuxfamily"
	@rsync -rapve 'ssh -i /home/pi/.ssh/tux2' \
		--delete ./www/irclogs/ $(_RD_TUXFAMILY)

tidylog:                       # convert raw logs file into the web form
	@./log-tidy.sh

download:                             # download irssi logs from remotes
	@./download.sh

log-split:
	@echo ":: Get logs from archive $(_ARCHIVE)"
	@zcat $(_ARCHIVE) | ./irssi-log-split.sh

html-clean:
	@find www/ -iname "*.html" -exec rm -fv {} +

html:
	@find www/ -iname "*.txt" | while read _f; do ./colorize.sh $$_f 2>/dev/null; done

daily: download log-split tidylog html tuxfamily
