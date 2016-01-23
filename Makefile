all:
	ls -1 *.env | xargs -L1 ./converge.sh
