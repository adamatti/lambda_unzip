TEST_FILE=test.txt
BUCKET_NAME=adamatti-test-bucket
BUILD_FOLDER=tmp/build
DOWNLOAD_FOLDER=tmp/s3-download

.DEFAULT_GOAL := help

.PHONY: help
help: ## show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

clean: ## remove generated files
	@rm -rf node_modules
	@rm -rf $(BUILD_FOLDER)
	@rm -rf $(DOWNLOAD_FOLDER)

install: ## install node dependencies
	@npm install

zip: ## Create a zip with a test file
	@cd tmp;zip test.zip $(TEST_FILE)

s3-upload: ## upload zip to s3
	@aws s3 cp tmp/test.zip s3://$(BUCKET_NAME)/

s3-ls: ## list s3 files
	@aws s3 ls s3://$(BUCKET_NAME)/

s3-download: ## download temp file extrated from s3
	@rm -rf $(DOWNLOAD_FOLDER)
	@mkdir -p $(DOWNLOAD_FOLDER)
	@aws s3 cp s3://$(BUCKET_NAME)/$(TEST_FILE) $(DOWNLOAD_FOLDER)

s3-rm: ## remove test files from s3
	@aws s3 rm s3://$(BUCKET_NAME)/test.zip
	@aws s3 rm s3://$(BUCKET_NAME)/$(TEST_FILE)

lint: ## run lint
	@npm run lint

build: lint ## package the node/lambda project
	@rm -rf $(BUILD_FOLDER)
	
	@mkdir $(BUILD_FOLDER)
	@cp -R src $(BUILD_FOLDER)/
	@cp -R node_modules $(BUILD_FOLDER)/
	@cp package.json $(BUILD_FOLDER)/
	@cp package-lock.json $(BUILD_FOLDER)/

	@cd $(BUILD_FOLDER);zip -qr build.zip ./

tf-lint: ## lint tf files
	@cd terraform;tflint

tf-apply: ## apply terraform changes (need to approve)
	@cd terraform/;terraform apply

tf-apply-approve: ## apply terraform changes with auto approve
	@cd terraform/;terraform apply -auto-approve

tf-destroy-approve: s3-rm ## destroy terraform creation
	@cd terraform/;terraform destroy -auto-approve

test-prepare: s3-rm s3-ls build tf-apply-approve ## prepate test (e.g. remove test files, build lambda, deploy)

test-run: s3-upload ## run the test (e.g. upload zip)

test-check: ## check test result (ls on s3)
	@$(MAKE) s3-ls