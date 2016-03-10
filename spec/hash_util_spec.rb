require 'spec_helper'
require 'hash_util'

describe HashUtil do


  describe '#stringify_keys', :nuke do

    context 'empty hash' do
      it 'returns empty hash' do
        expect(HashUtil::stringify_keys({})).to eq({})
      end
    end

    context 'simple hash with symbol key' do
      it 'returns hash with string key' do
        input_hash = {
          :foo => 'moo'
        }
        expect(HashUtil::stringify_keys(input_hash)).to eq({
                                                               'foo' => 'moo'
                                                           })
      end
    end

    context 'hash with symbol key and value that is hash with symbol key' do
      it 'returns hash with string key' do
        input_hash = {
            :foo => {
                :moo => 'cow'
            }
        }
        expect(HashUtil::stringify_keys(input_hash)).to eq({
                                                               'foo' => {
                                                                   'moo' => 'cow'
                                                               }
                                                           })
      end
    end


    context 'hash with symbol key and value that is array with hash' do
      it 'returns hash with string key' do
        input_hash = {
            :foo => [
                {
                  :moo => 'cow'
                },
                {
                  :zap => :yow
                },
                'somethingelse'
            ]
        }
        expect(HashUtil::stringify_keys(input_hash)).to eq({
                                                               'foo' => [
                                                                   {
                                                                     'moo' => 'cow'
                                                                   },
                                                                   {
                                                                     'zap' => :yow
                                                                   },
                                                                   'somethingelse'
                                                               ]
                                                           })
      end
    end
  end
end
