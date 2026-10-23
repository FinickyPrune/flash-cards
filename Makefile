SHELL := /bin/bash
.DEFAULT_GOAL := help

PROJECT     := FlashCards.xcodeproj
SCHEME      := FlashCards
BUNDLE_ID   := dev.finickyprune.FlashCards
DERIVED     := build/DerivedData
RESULTS     := build/results
SCREENSHOTS := build/screenshots
APP_PATH    := $(DERIVED)/Build/Products/Debug-iphonesimulator/$(SCHEME).app

# Resolved once per make invocation. Override with SIM_NAME="iPhone 17" or SIM_UDID=<udid>.
SIM_UDID = $(eval SIM_UDID := $$(shell scripts/sim.sh))$(SIM_UDID)

# Compact output: only warnings, errors and test results. CI overrides with --renderer github-actions.
XCBEAUTIFY_FLAGS ?= --quiet --is-ci --disable-colored-output --disable-logging
# pipefail keeps xcodebuild's exit code through the xcbeautify pipe
# (set inline: macOS ships GNU Make 3.81, which ignores .SHELLFLAGS).
XCODEBUILD = set -o pipefail && xcodebuild -project $(PROJECT) -scheme $(SCHEME) \
	-destination "platform=iOS Simulator,id=$(SIM_UDID)" \
	-derivedDataPath $(DERIVED) -skipPackagePluginValidation

# ONLY=FlashCardsTests/SmokeTests runs a single suite or test (xcodebuild -only-testing syntax).
ONLY ?=

.PHONY: help
help: ## Show available targets
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'

.PHONY: bootstrap
bootstrap: ## Install tools and git hooks
	@for tool in xcodegen swiftlint swiftformat xcbeautify jq; do \
		command -v $$tool >/dev/null || brew install $$tool; \
	done
	git config core.hooksPath .githooks
	@$(MAKE) --no-print-directory generate

.PHONY: generate
generate: ## Regenerate the Xcode project from project.yml (no-op if unchanged)
	@xcodegen generate --use-cache --quiet

.PHONY: build
build: generate ## Build the app for the simulator
	$(XCODEBUILD) build 2>&1 | xcbeautify $(XCBEAUTIFY_FLAGS)

.PHONY: test
test: generate ## Run unit tests (ONLY=Target/Suite[/test] to narrow)
	@rm -rf $(RESULTS)/unit.xcresult
	$(XCODEBUILD) test -only-testing:$(or $(ONLY),FlashCardsTests) \
		-resultBundlePath $(RESULTS)/unit.xcresult 2>&1 | xcbeautify $(XCBEAUTIFY_FLAGS)

.PHONY: test-ui
test-ui: generate ## Run UI tests
	@rm -rf $(RESULTS)/ui.xcresult
	$(XCODEBUILD) test -only-testing:$(or $(ONLY),FlashCardsUITests) \
		-resultBundlePath $(RESULTS)/ui.xcresult 2>&1 | xcbeautify $(XCBEAUTIFY_FLAGS)

.PHONY: lint
lint: ## Check formatting and lint rules
	swiftformat --lint .
	swiftlint lint --strict --quiet

.PHONY: format
format: ## Auto-fix formatting and fixable lint issues
	swiftformat --quiet .
	swiftlint lint --fix --quiet

.PHONY: check
check: lint test test-ui ## Full gate before opening a PR

.PHONY: run
run: build ## Build, install and launch in the simulator
	@xcrun simctl boot $(SIM_UDID) 2>/dev/null || true
	@open "$$(xcode-select -p)/Applications/Simulator.app" --args -CurrentDeviceUDID $(SIM_UDID) 2>/dev/null || true
	xcrun simctl install $(SIM_UDID) $(APP_PATH)
	xcrun simctl launch --terminate-running-process $(SIM_UDID) $(BUNDLE_ID)

# NAME=onboarding make screenshot -> build/screenshots/onboarding.png
NAME ?= screen
.PHONY: screenshot
screenshot: ## Save a simulator screenshot to build/screenshots/$(NAME).png
	@mkdir -p $(SCREENSHOTS)
	@xcrun simctl io $(SIM_UDID) screenshot --type=png $(SCREENSHOTS)/$(NAME).png >/dev/null
	@sips --resampleHeightWidthMax 1000 $(SCREENSHOTS)/$(NAME).png >/dev/null # keep images cheap to read
	@echo $(SCREENSHOTS)/$(NAME).png

.PHONY: clean
clean: ## Remove build artifacts and the generated project
	rm -rf build $(PROJECT)
