require 'spec_helper'
require 'results_dao'
require 'aws-sdk'

describe ResultsDAO do

  before(:all) do
    @results_dao = ResultsDAO.new
  end

  def insert_dummy_dynamodb_item(table_name)
    client = Aws::DynamoDB::Client.new
    result_item = {
        'result_label' => 'previous_result',
        'result' => 'something'
    }

    client.put_item item: result_item, table_name: table_name
  end

  def insert_malformed_dummy_dynamodb_item(table_name)
    client = Aws::DynamoDB::Client.new
    result_item = {
        'result_label' => 'previous_result',
        'foo' => 'something'
    }

    client.put_item item: result_item, table_name: table_name
  end

  describe '#nuke_results', :nuke do

    context 'table exists' do
      before(:all) do
        @stack_name = stack(stack_name: 'basicdynamodbfortesting',
                            path_to_stack: 'spec/cfndsl_test_templates/dynamodb_cfndsl.rb')
        insert_dummy_dynamodb_item 'footablefortesting'
      end

      it 'removes the table' do
        @results_dao.nuke_results 'footablefortesting'

        expect {
          client = Aws::DynamoDB::Client.new
          client.describe_table table_name: 'footablefortesting'
        }.to raise_error Aws::DynamoDB::Errors::ResourceNotFoundException
      end

      after(:all) do
        cleanup(@stack_name)
      end
    end

    context 'table does not exist' do
      it 'raises an exception' do
        expect {
          @results_dao.nuke_results 'footablefortesting2'
        }.to raise_error Aws::DynamoDB::Errors::ResourceNotFoundException
      end
    end
  end

  describe '#retrieve_prior_results', :retrieve do

    context 'table exists with result' do
      before(:all) do
        @stack_name = stack(stack_name: 'basicdynamodbfortesting',
                            path_to_stack: 'spec/cfndsl_test_templates/dynamodb_cfndsl.rb')
        insert_dummy_dynamodb_item 'footablefortesting'
      end

      it 'retrieves the result' do
        actual_result = @results_dao.retrieve_prior_results delta_name: 'footablefortesting'

        expect(actual_result).to eq 'something'
      end

      after(:all) do
        cleanup(@stack_name)
      end
    end

    context 'table exists without result' do
      before(:all) do
        @stack_name = stack(stack_name: 'basicdynamodbfortesting',
                            path_to_stack: 'spec/cfndsl_test_templates/dynamodb_cfndsl.rb')
      end

      it 'returns nil' do
        actual_result = @results_dao.retrieve_prior_results delta_name: 'footablefortesting'

        expect(actual_result).to eq nil
      end

      after(:all) do
        cleanup(@stack_name)
      end
    end

    context 'table exists with malformed result' do
      before(:all) do
        @stack_name = stack(stack_name: 'basicdynamodbfortesting',
                            path_to_stack: 'spec/cfndsl_test_templates/dynamodb_cfndsl.rb')
        insert_malformed_dummy_dynamodb_item 'footablefortesting'
      end

      it 'raises an exception' do
        expect {
          @results_dao.retrieve_prior_results delta_name: 'footablefortesting'
        }.to raise_error
      end

      after(:all) do
        cleanup(@stack_name)
      end
    end

    context 'table does not exist' do
      it 'returns nil' do
        actual_result = @results_dao.retrieve_prior_results delta_name: 'footablefortesting2'

        expect(actual_result).to eq nil
      end
    end
  end

  describe '#update_prior_result', :update do

    context 'table exists with result' do
      before(:all) do
        @stack_name = stack(stack_name: 'basicdynamodbfortesting',
                            path_to_stack: 'spec/cfndsl_test_templates/dynamodb_cfndsl.rb')
        insert_dummy_dynamodb_item 'footablefortesting'
      end

      it 'updates the result' do
        @results_dao.update_prior_result delta_name: 'footablefortesting', results: 'something2'

        actual_result = @results_dao.retrieve_prior_results delta_name: 'footablefortesting'

        expect(actual_result).to eq 'something2'
      end

      after(:all) do
        cleanup(@stack_name)
      end
    end

    context 'table exists without result' do
      before(:all) do
        @stack_name = stack(stack_name: 'basicdynamodbfortesting',
                            path_to_stack: 'spec/cfndsl_test_templates/dynamodb_cfndsl.rb')
      end

      it 'updates the results' do
        @results_dao.update_prior_result delta_name: 'footablefortesting', results: 'something2'

        actual_result = @results_dao.retrieve_prior_results delta_name: 'footablefortesting'

        expect(actual_result).to eq 'something2'
      end

      after(:all) do
        cleanup(@stack_name)
      end
    end

    context 'table exists with malformed result' do
      before(:all) do
        @stack_name = stack(stack_name: 'basicdynamodbfortesting',
                            path_to_stack: 'spec/cfndsl_test_templates/dynamodb_cfndsl.rb')
        insert_malformed_dummy_dynamodb_item 'footablefortesting'
      end

      it 'updates the results' do
        @results_dao.update_prior_result delta_name: 'footablefortesting', results: 'something2'

        actual_result = @results_dao.retrieve_prior_results delta_name: 'footablefortesting'

        expect(actual_result).to eq 'something2'
      end

      after(:all) do
        cleanup(@stack_name)
      end
    end

    context 'table does not exist' do
      it 'creates the table and updates the results' do
        @results_dao.update_prior_result delta_name: 'footablefortesting3', results: 'something2'

        actual_result = @results_dao.retrieve_prior_results delta_name: 'footablefortesting3'

        expect(actual_result).to eq 'something2'
      end

      after(:all) do
        @results_dao.nuke_results 'footablefortesting3'
      end
    end
  end
end
