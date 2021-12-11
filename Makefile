GIT_BRANCH ?= main
GIT_REMOTE ?= origin
RELEASE_TYPE ?= patch


test:
	go test .

snapshot:
	@$(info - Releasing $(PROJECT_NAME)-snapshot)
	@goreleaser release --snapshot --skip-publish --rm-dist



_quick-commit:
	git add .
	git commit -m "updating"
	git push
	git push --tags


_setup-versions:
	$(eval export CURRENT_VERSION=$(shell git ls-remote --tags $(GIT_REMOTE) | grep -v latest | awk '{ print $$2}'|grep -v 'stable'| sort -r --version-sort | head -n1|sed 's/refs\/tags\///g'))
	$(eval export NEXT_VERSION=$(shell semver -c -i $(RELEASE_TYPE) $(CURRENT_VERSION)))

all-versions:
	@git ls-remote --tags $(GIT_REMOTE)

current-version: _setup-versions
	@echo $(CURRENT_VERSION)

next-version: _setup-versions
	@echo $(NEXT_VERSION)

release: _setup-versions
	$(call git_push,"Released @ $(ENV)")
	@git tag $(NEXT_VERSION)
	@git push $(GIT_REMOTE) --tags
	@$(info - Releasing $(PROJECT_NAME)-snapshot)
	@goreleaser release --rm-dist

