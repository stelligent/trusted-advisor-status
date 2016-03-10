require 'spec_helper'
require 'trusted_advisor_status'
require 'aws-sdk'

describe TrustedAdvisorStatus do

  describe '#check_status', :nuke do

    context 'fail on error' do

      context 'error found' do
        before do
          @trusted_advisor_status = TrustedAdvisorStatus.new

          mock_error_result = double('result')
          allow(mock_error_result).to receive(:[]).with('status').and_return 'error'

          expect(@trusted_advisor_status).to receive(:discover_results) { [mock_error_result] }
        end

        it 'returns status code 1' do
          expect(@trusted_advisor_status.check_status(fail_on_error: true)).to eq 1
        end
      end

      context 'no error found' do
        before do
          @trusted_advisor_status = TrustedAdvisorStatus.new

          mock_warning_result = double('result')
          allow(mock_warning_result).to receive(:[]).with('status').and_return 'warning'

          expect(@trusted_advisor_status).to receive(:discover_results) { [mock_warning_result] }
        end

        it 'returns status code 0' do
          expect(@trusted_advisor_status.check_status(fail_on_error: true)).to eq 0
        end
      end
    end

    context 'fail on warning' do

      context 'error found' do
        before do
          @trusted_advisor_status = TrustedAdvisorStatus.new

          mock_error_result = double('result')
          allow(mock_error_result).to receive(:[]).with('status').and_return 'error'

          expect(@trusted_advisor_status).to receive(:discover_results) { [mock_error_result] }
        end

        it 'returns status code 1' do
          expect(@trusted_advisor_status.check_status(fail_on_warn: true)).to eq 1
        end
      end

      context 'warning found' do
        before do

          @trusted_advisor_status = TrustedAdvisorStatus.new

          mock_warning_result = double('result')
          allow(mock_warning_result).to receive(:[]).with('status').and_return 'warning'

          expect(@trusted_advisor_status).to receive(:discover_results) { [mock_warning_result] }
        end

        it 'returns status code 1' do
          expect(@trusted_advisor_status.check_status(fail_on_warn: true)).to eq 1
        end
      end

      context 'no warning or error found' do
        before do
          @trusted_advisor_status = TrustedAdvisorStatus.new

          mock_ok_result = double('result')
          allow(mock_ok_result).to receive(:[]).with('status').and_return 'ok'

          expect(@trusted_advisor_status).to receive(:discover_results) { [mock_ok_result] }
        end

        it 'returns status code 1' do
          expect(@trusted_advisor_status.check_status(fail_on_warn: true)).to eq 0
        end
      end
    end
  end
end
