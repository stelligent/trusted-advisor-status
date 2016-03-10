require 'spec_helper'
require 'results_differencer'


describe ResultsDifferencer do

  def extra_record
    json = <<-END
    {
        "check_id": "vjafUGJ9H0",
        "status": "error",
        "flagged_resources": [
          {
            "status": "error",
            "region": "us-east-1",
            "metadata": [
              "us-east-1",
              "ConSecDemo-InstanceSecurityGroup-123S2ACS241XT",
              "sg-1e65da66 (vpc-d7192db3)",
              "tcp",
              "22",
              "Red",
              "0.0.0.0/0"
            ]
          },
          {
            "status": "error",
            "region": "us-east-1",
            "metadata": [
              "us-east-1",
              "ConSecDemo-InstanceSecurityGroup-123S2ACS241XS",
              "sg-1e65da67 (vpc-d7192db3)",
              "tcp",
              "22",
              "Red",
              "0.0.0.0/0"
            ]
          }
        ]
    }
    END

    JSON.load(json)
  end

  def extra_resource
    json = <<-END
    {
        "check_id": "vjafUGJ9H0",
        "status": "error",
        "flagged_resources": [
          {
            "status": "error",
            "region": "us-east-1",
            "metadata": [
              "us-east-1",
              "ConSecDemo-InstanceSecurityGroup-123S2ACS241XT",
              "sg-1e65da66 (vpc-d7192db3)",
              "tcp",
              "22",
              "Red",
              "0.0.0.0/0"
            ]
          },
          {
            "status": "error",
            "region": "us-east-1",
            "metadata": [
              "us-east-1",
              "ConSecDemo-InstanceSecurityGroup-123S2ACS241XS",
              "sg-1e65da67 (vpc-d7192db3)",
              "tcp",
              "22",
              "Red",
              "0.0.0.0/0"
            ]
          },
          {
            "status": "error",
            "region": "us-east-1",
            "metadata": [
              "us-east-1",
              "ConSecDemo-JenkinsStack-1CYK6IIHZ3MLK-JenkinsSecurityGroup-1DF1N3DPNVI4P",
              "sg-365fe04e (vpc-d7192db3)",
              "tcp",
              "1-65535",
              "Red",
              "0.0.0.0/0"
            ]
          }
        ]
    }
    END

    JSON.load(json)
  end

  def one_less_resource
    json = <<-END
    {
        "check_id": "vjafUGJ9H0",
        "status": "error",
        "flagged_resources": [
          {
            "status": "error",
            "region": "us-east-1",
            "metadata": [
              "us-east-1",
              "ConSecDemo-InstanceSecurityGroup-123S2ACS241XT",
              "sg-1e65da66 (vpc-d7192db3)",
              "tcp",
              "22",
              "Red",
              "0.0.0.0/0"
            ]
          }
        ]
    }
    END

    JSON.load(json)
  end

  context 'two empty lists' do
    describe '#new_violations' do
      it 'returns no difference' do
        delta_results = ResultsDifferencer.new.new_violations prior: [], current: []

        expect(delta_results).to eq []
      end
    end

    describe '#fixed' do
      it 'returns no difference' do
        delta_results = ResultsDifferencer.new.fixed prior: [], current: []

        expect(delta_results).to eq []
      end
    end
  end

  context 'extra record in current' do

    describe '#new_violations' do
      it 'returns the extra record' do
        delta_results = ResultsDifferencer.new.new_violations prior: [], current: [extra_record]

        expect(delta_results).to eq [extra_record]
      end
    end

    describe '#fixed' do
      it 'returns no difference' do
        delta_results = ResultsDifferencer.new.fixed prior: [], current: [extra_record]

        expect(delta_results).to eq []
      end
    end
  end

  context 'one less record in current' do

    describe '#new_violations' do
      it 'returns the extra record' do
        delta_results = ResultsDifferencer.new.new_violations prior: [extra_record], current: []

        expect(delta_results).to eq []
      end
    end

    describe '#fixed' do
      it 'returns no difference' do
        delta_results = ResultsDifferencer.new.fixed prior: [extra_record], current: []

        expect(delta_results).to eq [extra_record]
      end
    end
  end

  context 'no changed record in current' do

    describe '#new_violations' do
      it 'returns no difference' do
        delta_results = ResultsDifferencer.new.new_violations prior: [extra_record], current: [extra_record]

        expect(delta_results).to eq []
      end
    end

    describe '#fixed' do
      it 'returns no difference' do
        delta_results = ResultsDifferencer.new.fixed prior: [extra_record], current: [extra_record]

        expect(delta_results).to eq []
      end
    end
  end

  context 'one extra flagged resource in current' do

    describe '#new_violations' do
      it 'returns the extra resource' do
        delta_results = ResultsDifferencer.new.new_violations prior: [extra_record], current: [extra_resource]

        json = <<-END
        {
        "check_id": "vjafUGJ9H0",
        "status": "error",
        "flagged_resources": [
          {
            "status": "error",
            "region": "us-east-1",
            "metadata": [
              "us-east-1",
              "ConSecDemo-JenkinsStack-1CYK6IIHZ3MLK-JenkinsSecurityGroup-1DF1N3DPNVI4P",
              "sg-365fe04e (vpc-d7192db3)",
              "tcp",
              "1-65535",
              "Red",
              "0.0.0.0/0"
            ]
          }
        ]
        }
        END

        changed_resource = JSON.load(json)

        expect(delta_results).to eq [changed_resource]
      end
    end

    describe '#fixed' do
      it 'returns no difference' do
        delta_results = ResultsDifferencer.new.fixed prior: [extra_record], current: [extra_resource]

        expect(delta_results).to eq []
      end
    end
  end

  context 'one less flagged resource in current' do

    describe '#new_violations' do
      it 'returns the extra record' do
        delta_results = ResultsDifferencer.new.new_violations prior: [extra_record], current: [one_less_resource]

        expect(delta_results).to eq []
      end
    end

    describe '#fixed' do
      it 'returns no difference' do
        delta_results = ResultsDifferencer.new.fixed prior: [extra_record], current: [one_less_resource]

        json = <<-END
        {
        "check_id": "vjafUGJ9H0",
        "status": "error",
        "flagged_resources": [
          {
            "status": "error",
            "region": "us-east-1",
            "metadata": [
              "us-east-1",
              "ConSecDemo-InstanceSecurityGroup-123S2ACS241XS",
              "sg-1e65da67 (vpc-d7192db3)",
              "tcp",
              "22",
              "Red",
              "0.0.0.0/0"
            ]
          }
        ]
        }
        END

        changed_resource = JSON.load(json)
        expect(delta_results).to eq [changed_resource]
      end
    end
  end


end

