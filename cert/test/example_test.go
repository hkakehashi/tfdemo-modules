package test

import (
	"crypto/tls"
	"fmt"
	"testing"
	"time"

	http_helper "github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestWebServerHttpRequest(t *testing.T) {
	opt := terraform.WithDefaultRetryableErrors(
		t,
		&terraform.Options{TerraformDir: "../example"},
	)
	defer terraform.Destroy(t, opt)

	terraform.InitAndApply(t, opt)

	domains := terraform.OutputList(
		t,
		opt,
		"domains",
	)

	assert.Equal(t, len(domains), 2)

	for _, domain := range domains {
		url := fmt.Sprintf("https://%s/status/200", domain)
		// HttpGetWithRetry repeatedly performs an HTTP GET on the given URL until the given status code and body are returned or until max
		// retries has been exceeded.
		http_helper.HttpGetWithRetry(
			t,
			url,
			&tls.Config{},
			200,           // expectedStatus
			"",            // expectedBody
			30,            // retries
			5*time.Second, // sleepBetweenRetries
		)
	}
}
