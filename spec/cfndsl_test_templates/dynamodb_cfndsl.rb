CloudFormation {

  DynamoDB_Table('rDynamoTable') {
    TableName 'footablefortesting'
    ProvisionedThroughput {
      ReadCapacityUnits 1
      WriteCapacityUnits 1
    }
    AttributeDefinitions [
                             {
                                 'AttributeName' => 'result_label',
                                 'AttributeType' => 'S'
                             }
                         ]
    KeySchema [
                  {
                      'AttributeName' => 'result_label',
                      'KeyType' => 'HASH'
                  }
              ]
  }
}
