This is a pet project, just a lambda(nodejs) to unzip files on s3

# How to use / evolve

- change variables on `terraform/terraform.tfvars`
- happy path
    - deploy lambda: `make install build tf-apply-approve`
    - upload a zip file: `make s3-upload`
    - check files on s3 bucked: `make s3-ls`
- destroy / clean all: `make tf-destroy-approve clean`
- check all commands: `make help`

# Optional tools

- [eslint](https://eslint.org/)
- [tflint](https://github.com/terraform-linters/tflint)
