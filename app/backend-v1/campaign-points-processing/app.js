require('dotenv').config({path: __dirname + '/.env'});
const { defaultProvider } = require("@aws-sdk/credential-provider-node");
const {
  SQSClient,
  ReceiveMessageCommand,
  DeleteMessageCommand,
  GetQueueAttributesCommand,
} = require("@aws-sdk/client-sqs");
const { SNSClient, PublishCommand } = require("@aws-sdk/client-sns");
const { DynamoDBClient } = require("@aws-sdk/client-dynamodb")
const {
  SecretsManagerClient,
  GetSecretValueCommand,
} = require("@aws-sdk/client-secrets-manager");
const mysql = require("mysql2");

const { validateTransactionData } = require("./src/validateData");
const {
  getApplicableCampaigns,
  updateUserReward,
  getUserPhone,
} = require("./src/DAO");
const { processRewards } = require("./src/rewardHandler");

const region = process.env.REGION;
const sqsQueueUrl = process.env.SQS_QUEUE_URL;
const userSqsQueueUrl = process.env.USER_SQS_QUEUE_URL;

// provider to retrieve AWS credentials from environment
const credentials = defaultProvider();
const sqs = new SQSClient({ credentials, region });
const ddb = new DynamoDBClient({ credentials, region });
const sns = new SNSClient({ credentials, region });
const secretsManager = new SecretsManagerClient({ credentials, region });

const sqsParams = {
  AttributeNames: ["SentTimestamp"],
  MessageAttributeNames: ["All"],
  QueueUrl: sqsQueueUrl,
  VisibilityTimeout: 20,
  WaitTimeSeconds: 20,
  MaxNumberOfMessages: 10,
};

const userSqsParams = {
  AttributeNames: ["All"],
  QueueUrl: userSqsQueueUrl,
  WaitTimeSeconds: 0,
}

const receiveMessage = async (sqlConnection) => {
  console.log("Polling for transaction messages");

  const receiveMessageCommand = new ReceiveMessageCommand(sqsParams);
  let transactionData, sqsReceiveResponse;

  try {
    sqsReceiveResponse = await sqs.send(receiveMessageCommand);
    console.log("Successfully received message:", sqsReceiveResponse);
  } catch (err) {
    console.log("Error receiving message from queue:", err);
    return;
  }

  if (sqsReceiveResponse.Messages) {
    for (message of sqsReceiveResponse.Messages) {
      receiptHandle = message.ReceiptHandle;

      transactionData = JSON.parse(JSON.parse(message.Body).Message);
      console.log(transactionData);

      try {
        await processTransaction(transactionData, sqlConnection);
      } catch (err) {
        console.log("Error processing message:", err);
      }

      const deleteMessageCommand = new DeleteMessageCommand({
        QueueUrl: sqsQueueUrl,
        ReceiptHandle: receiptHandle,
      });
      const sqsDeleteResponse = await sqs.send(deleteMessageCommand);
      console.log("Deleted message in queue:", sqsDeleteResponse);
      
    }
  }
};

const processTransaction = async (transactionData, sqlConnection) => {
  // validate transaction data
  if (!validateTransactionData(transactionData)) {
    console.log("Error: Transaction data invalid:", transactionData);
    return;
  } else {
    console.log("Transaction validated.");
  }

  // pre-process data
  transactionData.card_pan = transactionData.card_pan.replace(/-/g, "");

  // check if transaction qualifies for campaign
  const applicableCampaigns = await getApplicableCampaigns(
    ddb,
    transactionData
  );
  console.log("applicableCampaigns: ", applicableCampaigns);

  if (applicableCampaigns.length != 0) {
    const campaignData = applicableCampaigns[0];

    // handle applying campaign reward calculations
    const rewardAmount = processRewards(campaignData, transactionData);
    console.log(`Calculated rewardAmount: ${rewardAmount}`);

    // update database
    const updateRewardResponse = await updateUserReward(
      sqlConnection,
      rewardAmount,
      campaignData,
      transactionData
    );
    if (updateRewardResponse) console.log(`Successfully updated database.`);
    else console.log("Failed to update DB.");

    // retrieve user phone details
    const userPhoneData = await getUserPhone(sqlConnection, transactionData.id);
    const userPhoneNumber = `${userPhoneData[0].phone}`; // E.164 format

    console.log(`Retrieved user phone: ${userPhoneNumber}`);

  }

  
};

const app = async () => {
  // get secrets for sql parameters
  const getSecrets = async () => {
    try {
      const getSecretsCommand = new GetSecretValueCommand({
        SecretId: process.env.SECRET_ID,
      });
      const secretsResponse = await secretsManager.send(getSecretsCommand);
      console.log("Retrieved DB secrets.");
      return JSON.parse(secretsResponse.SecretString);
    } catch (err) {
      console.log("Failed to retrieve DB secrets:", err);
      return null;
    }
  };

  const secrets = await getSecrets();

  if (secrets === null) {
    console.log("Exiting due to failure to retrieve secrets.");
    return;
  };

  const sqlParams = {
    host: secrets.host,
    port: secrets.port,
    user: secrets.username,
    password: secrets.password,
    database: secrets.dbname,
  };

  // establish SQL connections
  const sqlConnection = mysql.createConnection(sqlParams);

  process.on('SIGTERM', () => {
    // gracefully close connections on termination
    sqlConnection.end();
  });

  while (true) {
    try {
      console.log("Checking user queue for messages to decide if processing should go ahead.");
      const checkUserQueueCommand = new GetQueueAttributesCommand(userSqsParams);
      const checkUserQueueResponse = await sqs.send(checkUserQueueCommand);

      if (checkUserQueueResponse.Attributes.ApproximateNumberOfMessages > 0) {
        setTimeout(() => console.log("Found messages in user queue, going to sleep."), 60000);
      }
      else {
        console.log("Running receiveMessage.");
        await receiveMessage(sqlConnection);
      }
    }
    catch (err) {
      setTimeout(() => console.log("Loop process encountered error, pausing process:", err), 60000)
    }
  };
};

app();