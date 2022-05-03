const { defaultProvider } = require("@aws-sdk/credential-provider-node");
const {
  SQSClient,
  ReceiveMessageCommand,
  DeleteMessageCommand,
} = require("@aws-sdk/client-sqs");
const {
  SecretsManagerClient,
  GetSecretValueCommand,
} = require("@aws-sdk/client-secrets-manager");
const mysql = require("mysql2");

const { insertUser } = require("./src/DAO");

const region = process.env.REGION;
const sqsQueueUrl = process.env.SQS_QUEUE_URL;

// provider to retrieve AWS credentials from environment
const credentials = defaultProvider();
const sqs = new SQSClient({ credentials, region });
const secretsManager = new SecretsManagerClient({ credentials, region });

const sqsParams = {
  AttributeNames: ["SentTimestamp"],
  MessageAttributeNames: ["All"],
  QueueUrl: sqsQueueUrl,
  VisibilityTimeout: 20,
  WaitTimeSeconds: 20,
  MaxNumberOfMessages: 10,
};

const receiveMessage = async (sqlConnection) => {
  console.log("Polling for user data messages");
  const receiveMessageCommand = new ReceiveMessageCommand(sqsParams);
  let userData, sqsReceiveResponse;

  try {
    sqsReceiveResponse = await sqs.send(receiveMessageCommand);
    console.log("Successfully received message");
  } catch (err) {
    console.log("Error receiving message from queue:", err);
  }

  if (sqsReceiveResponse.Messages) {
    let messageBatch = [];
    
    for (message of sqsReceiveResponse.Messages) {
      receiptHandle = message.ReceiptHandle;

      if (receiptHandle) {
        try {
          const deleteMessageCommand = new DeleteMessageCommand({
            QueueUrl: sqsQueueUrl,
            ReceiptHandle: receiptHandle,
          });
          const sqsDeleteResponse = await sqs.send(deleteMessageCommand);
  
          console.log("Deleted message in queue");
  
          userData = JSON.parse(message.Body);

          console.log("userData: ", userData);
  
          // pre-process data
          userData.card_pan = userData.card_pan.replace(/-/g, "");
  
          // await processUserData(userData, sqlConnection);
  
          // add to batch
          messageBatch.push(userData);
        } catch (err) {
          console.log("Error processing message:", err);
        }
      }
      else {
        console.log("Message had no receipt handle.");
      }
    }

    const insertUserResponse = await insertUser(sqlConnection, messageBatch);
    if (insertUserResponse) console.log(`Successfully updated database.`);
    else console.log("Failed to update DB for:", messageBatch);
  }
  else {
    console.log("Empty response: ", sqsReceiveResponse);
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
      console.log("Running receiveMessage.")
      await receiveMessage(sqlConnection);
    }
    catch (err) {
      setTimeout(() => console.log("Loop process encountered error, pausing process:", err), 60000);
    }
  };
};

app();