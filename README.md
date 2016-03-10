# trusted-advisor-status

## Description

This gem provides a command line tool to retrieve a JSON formatting of AWS Trusted Advisor results
for the performance and security categories.

Suppressed resources are ignored.

It does not mess with refreshing the status of the results - it takes whatever is current from AWS.

## Usage

### "Standalone"

To retrieve a JSON dump of all the current Trusted Advisor results:

    trusted-advisor-status

By default, the exit status code will be 0 for success.

In order to fail when warnings or errors are detected:

    trusted-advisor-status --fail-on-warn
   
In order to fail when just errors are detected:
      
    trusted-advisor-status --fail-on-error
  
### Delta

To retrieve a delta of Trusted Advisor results from a past execution of trusted-advisor-results:

    trusted-advisor-status --delta-name myhistory

The label of the delta, "myhistory" in this case, is arbitrary, but must be used across invocations
to track the delta.

If no delta exists, the current full baseline result is stored and used for the next delta.

The fail-on-* flags will observe the new violations in a delta and ignore any "fixes".

### Cleanup of Delta

The result delta happens to be stored in DynamoDB.  To wipe out a given delta history:

    wipe-trusted-advisory-history --delta-name myhistory
