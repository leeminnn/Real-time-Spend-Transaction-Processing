// Adapter
class CampaignTransaction {
  constructor(campaignData, transactionData) {
    this.rewardType = campaignData.reward.S;
    this.rate = parseFloat(campaignData.rate.N);
    this.amount = parseFloat(transactionData.amount);
  }
}

// Chain of Responsibility Behavioural Design Pattern
class RewardHandler {
  setNextHandler(nextHandler) {}
  handleReward(campaignTransaction) {
    console.log(`Unable to handle reward for: ${campaignTransaction.rewardType}`);
    return 0;
  }
}

class MilesHandler extends RewardHandler {
  constructor(){
    super();
    this.nextHandler = new RewardHandler();
  }
  
  setNextHandler(nextHandler) {
    this.nextHandler = nextHandler;
  }

  handleReward(campaignTransaction) {
    if (campaignTransaction.rewardType === 'miles') {
      return campaignTransaction.rate * campaignTransaction.amount;
    }
    else {
      return this.nextHandler.handleReward(campaignTransaction);
    }
  }
}

class PointsHandler extends RewardHandler {
  constructor(){
    super();
    this.nextHandler = new RewardHandler();
  }
  
  setNextHandler(nextHandler) {
    this.nextHandler = nextHandler;
  }

  handleReward(campaignTransaction) {
    if (campaignTransaction.rewardType === 'points') {
      return campaignTransaction.rate * campaignTransaction.amount; 
    }
    else {
      return this.nextHandler.handleReward(campaignTransaction);
    }
  }
}

class CashbackHandler extends RewardHandler {
  constructor(){
    super();
    this.nextHandler = new RewardHandler();
  }
  
  setNextHandler(nextHandler) {
    this.nextHandler = nextHandler;
  }

  handleReward(campaignTransaction) {
    if (campaignTransaction.rewardType === 'cashback') {
      return campaignTransaction.rate/100 * campaignTransaction.amount;
    }
    else {
      return this.nextHandler.handleReward(campaignTransaction);
    }
  }
}

function processRewards(campaignData, transactionData) {
  // create Chain
  const milesHandler = new MilesHandler();
  const pointsHandler = new PointsHandler();
  const cashbackHandler = new CashbackHandler();
  milesHandler.setNextHandler(pointsHandler);
  pointsHandler.setNextHandler(cashbackHandler);

  // start handling
  return milesHandler.handleReward(new CampaignTransaction(campaignData, transactionData));
}

module.exports = { processRewards };