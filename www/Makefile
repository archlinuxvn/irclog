_RD_TUXFAMILY = kyanh@ssh.tuxfamily.org:~/archlinuxvn/archlinuxvn.tuxfamily.org-web/htdocs/

default:                             # list all section of this Makefile
	@cat Makefile | grep -E "^[a-z]+.*:"

tuxfamily:                         # upload web logs to tuxfamily server
	@echo ":: Uploading log files to tuxfamily"
	@rsync -rapve 'ssh -i /home/pi/.ssh/tux2' \
		./index.html $(_RD_TUXFAMILY)/index.html
