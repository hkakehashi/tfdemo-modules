package test

import (
	"fmt"
	"strings"
	"testing"
	"time"

	http_helper "github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
)

func TestServiceModule(t *testing.T) {
	var testCases = []struct {
		name string
		expectedStatus int
		expectedBody string
		varfile []string
	}{
		{
			"withACL",
			403,
			"",
			[]string{"example_with_acl.tfvars"},
		},
		{
			"withoutACL",
			200,
			"コンニチハ",
			[]string{"example_min.tfvars"},
		},
	}

	// Terraform working directory
	workingDir := "../example/"

	// Run terraform destroy at the end of the test
	defer test_structure.RunTestStage(t, "teardown", func() {
		opt := test_structure.LoadTerraformOptions(t, workingDir)
		terraform.Destroy(t, opt)
	})

	// Run terraform init
	test_structure.RunTestStage(t, "init", func() {
		opt := terraform.WithDefaultRetryableErrors(
			t,
			&terraform.Options{TerraformDir: workingDir},
		)
		terraform.Init(t, opt)
	})

	for _, tt := range testCases {
		// Run terraform apply
		test_structure.RunTestStage(t, "apply "+tt.name, func() {
			opt := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
				TerraformDir: workingDir,
				VarFiles:         tt.varfile,
			})
			test_structure.SaveTerraformOptions(t, workingDir, opt)
			terraform.Apply(t, opt)
		})

		// Validate that the service is deployed and can return the expected HTTP responses
		test_structure.RunTestStage(t, "validate "+tt.name, func() {
			opt := test_structure.LoadTerraformOptions(t, workingDir)

			domain := terraform.Output(t, opt, "domain")
			url := fmt.Sprintf("http://%s/encoding/utf8", domain)
			maxRetries := 30
			sleepBetweenRetries := 5 * time.Second

			customValidationFn := func(status int, body string) bool {
				return status == tt.expectedStatus && strings.Contains(body,tt.expectedBody) 
			}

			// HttpGetWithRetryWithCustomValidation repeatedly performs an HTTP GET on the given URL until the given validation function returns true or max retries
			// has been exceeded.
			http_helper.HttpGetWithRetryWithCustomValidation(
				t,
				url,
				nil,
				maxRetries,
				sleepBetweenRetries,
				customValidationFn,
			)
		})
	}
}
