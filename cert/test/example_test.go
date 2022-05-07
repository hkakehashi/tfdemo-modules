package test

import (
	"crypto/tls"
	"fmt"
	"testing"
	"time"

	http_helper "github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/require"
)

func TestCertModule(t *testing.T) {
	opt := terraform.WithDefaultRetryableErrors(
		t,
		&terraform.Options{
			TerraformDir: "../example",
		},
	)
	defer terraform.Destroy(t, opt)

	// Checks specific values in the plan output
	planStruct := terraform.InitAndPlanAndShowWithStructNoLogTempPlanFile(t, opt)
	subscription, exists := planStruct.ResourcePlannedValuesMap["module.cert.fastly_tls_subscription.subscription"]
	require.True(t, exists, "fastly_tls_subscription resource must exist")

	certAuthority, exists := subscription.AttributeValues["certificate_authority"]
	require.True(t, exists, "missing certificate_authority")
	require.Equal(t, "lets-encrypt", certAuthority)

	// Checks the apply output's add/change/destroy counts
	applyString := terraform.Apply(t, opt)
	resourceCounts := terraform.GetResourceCount(t, applyString)
	require.Equal(t, 7, resourceCounts.Add)
	require.Equal(t, 0, resourceCounts.Change)
	require.Equal(t, 0, resourceCounts.Destroy)

	// Checks specific values in the output
	domains := terraform.OutputList(t, opt, "domains")
	require.Equal(t, 2, len(domains))

	// Perform HTTP request testing
	expectedStatus := 200
	expectedBody := ""
	maxRetries := 30
	sleepBetweenRetries := 5 * time.Second

	for _, domain := range domains {
		url := fmt.Sprintf("https://%s/status/200", domain)
		// HttpGetWithRetry repeatedly performs an HTTP GET on the given URL until the given status code and body are returned or until max
		// retries has been exceeded.
		http_helper.HttpGetWithRetry(
			t,
			url,
			&tls.Config{},
			expectedStatus,
			expectedBody,
			maxRetries,
			sleepBetweenRetries,
		)
	}
}
