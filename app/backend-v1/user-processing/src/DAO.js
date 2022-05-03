async function insertUser(con, messageBatch) {
  con.connect();
  console.log("insertUser started");

  let userData;
  
  let userInsertValues = ``;
  let cardInsertValues = ``;

  for (let i = 0; i < messageBatch.length; i++) {
    userData = sanitizeData(messageBatch[i]);
    
    if (i == messageBatch.length-1) {
      userInsertValues += `('${userData.id}', '${userData.first_name}', '${userData.last_name}',
      '${userData.email}', '${userData.phone}', '${userData.created_at}',
      '${userData.updated_at}') `
    }
    else {
      userInsertValues += `('${userData.id}', '${userData.first_name}', '${userData.last_name}',
      '${userData.email}', '${userData.phone}', '${userData.created_at}',
      '${userData.updated_at}'), `
    }

    if (i == messageBatch.length-1) {
      cardInsertValues += `('${userData.card_id}',
                        '${userData.id}',
                        '${userData.card_pan}',
                        '${userData.card_type}') `
    }
    else {
      cardInsertValues += `('${userData.card_id}',
                        '${userData.id}',
                        '${userData.card_pan}',
                        '${userData.card_type}'), `
    }
  }

  console.log("userInsertValues: ", userInsertValues)

  // INSERT USER
  const addUserQuery = `
  INSERT INTO
    User
    (
      id, firstName, lastName,
      email, phone, createdAt,
      updatedAt
    )
  VALUES ` + userInsertValues +
  `ON DUPLICATE KEY
  UPDATE
    firstName = VALUES(firstName),
    lastName = VALUES(lastName),
    email = VALUES(email),
    phone = VALUES(phone),
    createdAt = VALUES(createdAt),
    updatedAt = VALUES(updatedAt);
  `;

  // insert into User table if not exists
  const addUserResponse = await con.promise().query(
    addUserQuery
  );
  console.log('addUserResponse: ', addUserResponse);

  // INSERT USERCARD
  const addUserCardQuery = `
  INSERT INTO
    UserCard
    (
      cardId,
      userId,
      cardNumber,
      cardType
    )
  VALUES ` + cardInsertValues +
  `ON DUPLICATE KEY
  UPDATE
    userId = VALUES(userId),
    cardNumber = VALUES(cardNumber),
    cardType = VALUES(cardType);
  `;

  // insert into UserCard table if not exists
  const addUserCardResponse = await con.promise().query(
    addUserCardQuery
  );
  console.log('addUserCardResponse: ', addUserCardResponse);

  return true;
}

function sanitizeData(userData) {
  // neutralize quotes in names
  userData.first_name = neutralizeQuotes(userData.first_name);
  userData.last_name = neutralizeQuotes(userData.last_name);
  userData.email = neutralizeQuotes(userData.email);

  return userData;
}

function neutralizeQuotes(str) {
  const quoteIndexes = [...str.matchAll(new RegExp("'", 'gi'))].map(a => a.index);
  for (index of quoteIndexes) {
    str = str.slice(0, index) + "'" + str.slice(index);
  }
  return str;
}

module.exports = { insertUser }