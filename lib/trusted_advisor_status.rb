require 'aws-sdk'
require 'json'

class TrustedAdvisorStatus


  def check_status(categories:,
                   fail_on_warn: false,
                   fail_on_error: false)

    results = not_ok_check_results(categories: categories)

    json_results = jsonify(results)
    
    render_results(json_results)

    if fail_on_error
      error_found = results.find { |result| result.status == 'error' }
      error_found.nil? ? 0 : 1
    elsif fail_on_warn
      warning_fond = results.find { |result| result.status == 'error' or result.status == 'warning' }
      warning_fond.nil? ? 0 : 1
    else
      0
    end
  end

  def not_ok_check_results(categories:)

    # the region is on purpose - support intfc is global, but can't find endpoint outside of us-east-1
    support = Aws::Support::Client.new region: 'us-east-1'

    describe_trusted_advisor_checks_response = support.describe_trusted_advisor_checks language: 'en'

    if categories.nil?
      checks = describe_trusted_advisor_checks_response.checks
    else
      checks = describe_trusted_advisor_checks_response.checks.select { |check| categories.include? check.category }
    end

    checks.reduce([]) do |aggregate, check|
      describe_trusted_advisor_check_result_response = support.describe_trusted_advisor_check_result check_id: check.id,
                                                                                                     language: 'en'

      if describe_trusted_advisor_check_result_response.result.status != 'ok'
        aggregate << describe_trusted_advisor_check_result_response.result
      end

      aggregate
    end

    # resp.result.check_id #=> String
    # resp.result.timestamp #=> String
    # resp.result.status #=> String

    # resp.result.resources_summary.resources_processed #=> Integer
    # resp.result.resources_summary.resources_flagged #=> Integer
    # resp.result.resources_summary.resources_ignored #=> Integer
    # resp.result.resources_summary.resources_suppressed #=> Integer

    # resp.result.flagged_resources #=> Array
    # resp.result.flagged_resources[0].status #=> String
    # resp.result.flagged_resources[0].region #=> String
    # resp.result.flagged_resources[0].resource_id #=> String
    # resp.result.flagged_resources[0].is_suppressed #=> true/false
    # resp.result.flagged_resources[0].metadata #=> Array
    # resp.result.flagged_resources[0].metadata[0] #=> String
  end

  private

  def render_results(json_results)
    puts json_results
  end

  def jsonify(results)
    results_hashes = results.map { |result| result.to_h }
    JSON.pretty_generate(results_hashes)
  end
end