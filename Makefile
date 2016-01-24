plan apply output destroy:
	@make converge ACTION=$@

converge:
	@ls -1 *.env | xargs -L1 ./converge.sh $(ACTION)
