GOLANGCI_VERSION = v1.55.0

help: ## show help, shown by default if no target is specified
	@grep -E '^[0-9a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

test: ## run tests
	go test -timeout 10s -race ./...

test-coverage: ## run unit tests and create test coverage
	go test -timeout 10s ./... -coverprofile .testCoverage -covermode=atomic -coverpkg=./...

test-coverage-web: test-coverage ## run unit tests and show test coverage in browser
	go tool cover -func .testCoverage | grep total | awk '{print "Total coverage: "$$3}'
	go tool cover -html=.testCoverage

install: ## install all binaries
	go install -buildvcs=true .

install-linters: ## install all linters
	go install github.com/golangci/golangci-lint/cmd/golangci-lint@${GOLANGCI_VERSION}

release-snapshot: ## build release binaries from current git state as snapshot
	goreleaser release --snapshot --clean

build: ## build the goscrape binary
	go build -o goscrape main.go

scrape: build ## run web scraping on the specified URL
	@echo "Usage: make scrape URL='<url>'"
	@[ -n "$(URL)" ] || ( echo ">> URL is not specified"; false )
	$(eval PATH := $(shell echo $(URL) | sed 's|https://[^/]*||'))
	$(eval INCLUDE := $(PATH).*)
	$(eval SPECIFICPATH := $(PATH))
	$(eval OUTPUT := ./output)
	$(eval USERAGENT := Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html))
	@./goscrape --include '$(INCLUDE)' --output '$(OUTPUT)' --useragent '$(USERAGENT)' --specificpath '$(SPECIFICPATH)' '$(URL)'
