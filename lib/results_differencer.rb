require 'set'

class ResultsDifferencer

  def fixed(prior:,
            current:)
    
    prior_hash = {}
    prior.each { |result| prior_hash[result['check_id']] = result }

    current_hash = {}
    current.each { |result| current_hash[result['check_id']] = result }

    prior_ids = prior.map { |result| result['check_id'] }
    current_ids = current.map { |result| result['check_id'] }

    fixed_check_ids = prior_ids - current_ids
    same_check_ids = prior_ids - fixed_check_ids

    delta = []

    same_check_ids.each do |check_id|
      if prior_hash[check_id]['flagged_resources'] - current_hash[check_id]['flagged_resources'] != []
        # be ware of pulling the rug out from under your own feet?
        prior_hash[check_id]['flagged_resources'] -= current_hash[check_id]['flagged_resources']
        delta << prior_hash[check_id]
      end
    end

    fixed_check_ids.each { |check_id| delta << prior_hash[check_id] }

    delta
  end

  def new_violations(prior:,
                     current:)

    prior_hash = {}
    prior.each { |result| prior_hash[result['check_id']] = result }

    current_hash = {}
    current.each { |result| current_hash[result['check_id']] = result }

    prior_ids = prior.map { |result| result['check_id'] }
    current_ids = current.map { |result| result['check_id'] }

    new_check_ids = current_ids - prior_ids
    same_check_ids = current_ids - new_check_ids

    delta = []

    same_check_ids.each do |check_id|
      if current_hash[check_id]['flagged_resources'] - prior_hash[check_id]['flagged_resources'] != []
        # be ware of pulling the rug out from under your own feet?
        current_hash[check_id]['flagged_resources'] -= prior_hash[check_id]['flagged_resources']
        delta << current_hash[check_id]
      end
    end

    new_check_ids.each { |check_id| delta << current_hash[check_id] }

    delta
  end

end