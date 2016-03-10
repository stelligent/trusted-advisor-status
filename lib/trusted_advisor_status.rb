require 'aws-sdk'
require 'json'
require_relative 'results_dao'
require_relative 'results_differencer'
require_relative 'hash_util'

class TrustedAdvisorStatus


  def check_status(categories: %w(security performance),
                   fail_on_warn: false,
                   fail_on_error: false,
                   delta_name: nil)

    results = discover_results(categories: categories,
                               delta_name: delta_name)

    render_results(results)

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

  def discover_results(categories:, delta_name:)
    results_dao = ResultsDAO.new

    full_results = not_ok_check_results(categories: categories)
    if delta_name.nil?
      full_results
    else
      prior_results = results_dao.retrieve_prior_results delta_name: delta_name
      if prior_results.nil?
        delta_results = full_results
      else
        diff = ResultsDifferencer.new
        new_violations = diff.new_violations(prior: prior_results,
                                             current: full_results)
        fixes = diff.fixed(prior: prior_results,
                           current: full_results)

        delta_results = {
          'new_violation' => new_violations,
          'fixes' => fixes
        }
      end
      results_dao.update_prior_result(delta_name: delta_name, results: full_results)

      delta_results
    end
  end

  private

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
        hash_result = describe_trusted_advisor_check_result_response.result.to_h

        hash_result.delete :timestamp
        hash_result.delete :resources_summary
        hash_result.delete :category_specific_summary

        hash_result[:description] = check.name

        unless hash_result[:flagged_resources].nil?
          hash_result[:flagged_resources] = hash_result[:flagged_resources].reject do |flagged_resource|
            is_suppressed = flagged_resource[:is_suppressed]

            flagged_resource.delete :resource_id
            flagged_resource.delete :is_suppressed

            is_suppressed
          end
        end

        aggregate << HashUtil::stringify_keys(hash_result)
      end

      aggregate
    end
  end

  def render_results(results)
    puts JSON.pretty_generate(results)
  end
end