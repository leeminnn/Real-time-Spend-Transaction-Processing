require('dotenv').config({ path: __dirname + '/.env' });
const { SNSClient, PublishCommand } = require("@aws-sdk/client-sns");
const { defaultProvider } = require("@aws-sdk/credential-provider-node");

exports.handler = async (request) => {
  const region = process.env.REGION;

  // provider to retrieve AWS credentials from environment
  const credentials = defaultProvider();
  const sns = new SNSClient({ credentials, region });

  // brief check to ensure request body is not completely empty
  if (Object.entries(request).length === 0) {
    console.log("Request body empty.");
    return {
      statusCode: 400,
      message: "Request rejected, request body is empty."
    }
  }

  // set publish parameters
  const params = {
    Message: JSON.stringify(request),
    TopicArn: process.env.TOPIC_ARN,
    MessageGroupId: 'transaction-api',
  }

  const command = new PublishCommand(params);

  try {
    const response = await sns.send(command);

    console.log("Successfully sent to topic:", response.MessageId);
    return {
      statusCode: 200,
      message: "Transaction Received"
    }
  } catch (err) {
    console.log("Error when sending to topic:", err);
    return {
      statusCode: 500,
      message: "Internal Server Error"
    }
  }
}