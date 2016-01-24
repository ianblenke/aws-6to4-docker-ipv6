plan:
	@make converge ACTION=plan
apply:
	@make converge ACTION=apply
destroy:
	@make converge ACTION=destroy

converge:
	@ls -1 *.env | xargs -L1 ./converge.sh $(ACTION)
