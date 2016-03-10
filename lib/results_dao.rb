require 'aws-sdk'

class ResultsDAO

  def nuke_results(delta_name)
    table = dynamo_db.table(delta_name)

    table.delete

    client.wait_until(:table_not_exists, table_name: delta_name)
  end

  def retrieve_prior_results(delta_name:)
    if table_exists? delta_name
      table = dynamo_db.table(delta_name)

      item_response = table.get_item key: {
                                            'result_label' => 'previous_result'
                                          }
      unless item_response.item.nil?
        item = item_response.item['result']
        if item.nil?
          raise "Result key must have value in prior results: #{item_response.item}"
        else
          item
        end
      end
    else
      nil
    end
  end

  def update_prior_result(delta_name:, results:)
    conditionally_create_table table_name: delta_name

    table = dynamo_db.table(delta_name)
    result_item = {
      'result_label' => 'previous_result',
      'result' => results
    }

    table.put_item item: result_item
  end

  private

  def conditionally_create_table(table_name:)
    unless table_exists? table_name
      dynamo_db.create_table attribute_definitions: [
                               {
                                 attribute_name: 'result_label',
                                 attribute_type: 'S'
                               }
                             ],
                             table_name: table_name,
                             key_schema: [
                               {
                                 attribute_name: 'result_label',
                                 key_type: 'HASH'
                               }
                             ],
                             provisioned_throughput: {
                               read_capacity_units: 1,
                               write_capacity_units: 1
                             }

      client.wait_until(:table_exists, table_name: table_name)
    end
  end


  def table_exists?(table_name)
    found_table = dynamo_db.tables.find { |table| table.name == table_name }
    not found_table.nil?
  end

  def client
    Aws::DynamoDB::Client.new
  end

  def dynamo_db
    Aws::DynamoDB::Resource.new(client: client)
  end
end