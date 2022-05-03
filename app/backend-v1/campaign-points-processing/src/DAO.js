const { ScanCommand } = require("@aws-sdk/client-dynamodb")

async function getApplicableCampaigns(client, data) {

  let parts;
  if (data.transaction_date.includes("/")) {
    parts = data.transaction_date.split("/");
  }
  else if (data.transaction_date.includes("-")) {
    parts = data.transaction_date.split("-");
  }
  const day = parseInt(parts[0])+1;
  const month = parts[1]-1;
  const year = parts[2];
  
  const txn_date = new Date(year, month, day).toISOString();

  const scanParams = {
    TableName: "itsag1t5_campaigns",
    FilterExpression: `
      card = :cardType
      AND merchant = :merchant
      AND #min <= :amount
      AND startDate <= :transactionDate
      AND endDate > :transactionDate
    `,
    ExpressionAttributeNames: {
      "#min": "min",
    },
    ExpressionAttributeValues: {
      ":cardType": { S: data.card_type},
      ":merchant": { S: data.merchant},
      ":amount": {N: data.amount},
      ":transactionDate": { S: txn_date},
    }
  }
  
  const scanCommand = new ScanCommand(scanParams);
  const scanResponse = await client.send(scanCommand);

  return scanResponse.Items;
}

async function updateUserReward(con, rewardAmount, campaignData, transactionData) {
  con.connect();

  // insert spending if not exists
  const spendingQuery = await con.promise().query(
    `
    INSERT INTO
      Spending
      (
        id, transactionId, merchant,
        mcc, currency, amount,
        transactionDate, cardId
      )
    VALUES
      (
        '${transactionData.id}', '${transactionData.transaction_id}', '${transactionData.merchant}',
        '${transactionData.mcc}', '${transactionData.currency}', ${transactionData.amount},
        '${transactionData.transactionDate}', '${transactionData.card_id}'
      )
    ON DUPLICATE KEY
    UPDATE
      currency='${transactionData.currency}',
      amount='${transactionData.amount}',
      transactionDate='${transactionData.transactionDate}';
    `
  );
  console.log('spendingQuery: ', spendingQuery)

  // insert (or update if exists) user rewards
  const rewardBalanceQuery = await con.promise().query(
    `
    INSERT INTO
      UserRewardBalance (userId, rewardType, balance)
    VALUES
      ('${transactionData.id}', '${campaignData.reward}', ${rewardAmount})
    ON DUPLICATE KEY
    UPDATE
      balance = balance + ${rewardAmount};
    `
  );
  console.log('rewardBalanceQuery', rewardBalanceQuery);

  // insert user reward history
  let remarks;
  if (campaignData.reward === 'cashback') {
    remarks = `Get ${campaignData.rate} ${campaignData.reward} per dollar!`
  }
  else {
    remarks = `Get ${campaignData.rate}% in cashback!`;
  }
  const rewardHistoryQuery = await con.promise().query(
    `
    INSERT INTO
      RewardHistory (spendingId, rewardType, value, remarks)
    VALUES
      (
        '${transactionData.id}', '${campaignData.reward}', ${rewardAmount}, '${remarks}'
      )
    ON DUPLICATE KEY
    UPDATE
      value = ${rewardAmount},
      remarks = '${remarks}';
    `
  );
  console.log('rewardHistoryQuery: ', rewardHistoryQuery)

  return true;
}

async function getUserPhone(con, userId) {
  con.connect();

  // retrieve user phone number
  const userQuery = await con.promise().query(
    `
    SELECT
      phone
    FROM
      User
    WHERE
      id = '${userId}'
    LIMIT
      1;
    `
  );

  return userQuery[0];
}

module.exports = { getApplicableCampaigns, updateUserReward, getUserPhone };