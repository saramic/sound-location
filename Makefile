.DEFAULT_GOAL := usage

# user and repo
USER        = $$(whoami)
CURRENT_DIR = $(notdir $(shell pwd))

# terminal colours
RED     = \033[0;31m
GREEN   = \033[0;32m
YELLOW  = \033[0;33m
NC      = \033[0m

.PHONY: location-demo
location-demo:
	pushd apps/location-demo && \
		npm install && \
		npm run dev -- --open && \
		popd

.PHONY: usage
usage:
	@echo
	@echo "Hi ${GREEN}${USER}!${NC} Welcome to ${RED}${CURRENT_DIR}${NC}"
	@echo
	@echo "Demos"
	@echo
	@echo "${YELLOW}make location-demo${NC}   run location demo"
	@echo
