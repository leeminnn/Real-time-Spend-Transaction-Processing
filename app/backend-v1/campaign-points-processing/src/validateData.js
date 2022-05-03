const moment = require("moment");

function compareObjectKeys(...objects) {
  const allKeys = objects.reduce(
    (keys, object) => keys.concat(Object.keys(object)),
    []
  );
  const union = new Set(allKeys);
  return objects.every((object) => union.size === Object.keys(object).length);
}

function validateTransactionData(data) {
  validationFunctions = {
    id: (val) => val.length == 36,
    transaction_id: (val) => val.length == 64,
    merchant: (val) => val !== "",
    mcc: (val) => !isNaN(val),
    currency: (val) => val.length == 3,
    amount: (val) => !isNaN(val),
    transaction_date: (val) => val !== "",
    card_id: (val) => val.length == 36,
    card_pan: (val) => val !== "",
    card_type: (val) => val !== "",
  };

  if (!compareObjectKeys(validationFunctions, data)) {
    return false;
  } else if (
    !Object.entries(data).every(([key, value]) =>
      validationFunctions[key](value)
    )
  ) {
    return false;
  }
  return true;
}

module.exports = { validateTransactionData };
