import React from "react";
import Image from "next/image";
import moment from "moment";

const CampaignModal = ({ data, close }) => {
  const { card, description, startDate, endDate, imageURL, merchant } = data;

  const convertCard = (cardType) => {
    switch (cardType) {
      case "scis_shopping":
        return "SCIS Shopping Card";
      case "scis_premium":
        return "SCIS Premium Card";
      case "scis_platinum":
        return "SCIS Platinum Card";
      case "scis_freedom":
        return "SCIS Freedom Card";
      default:
        return "Invalid Card Type";
    }
  };

  return (
    <div className="mt-6">
      <div className="flex flex-col space-y-4">
        <div className="text-indigo-500">
          <h3 className="text-xl">{merchant} Campaign</h3>
        </div>
        <div className="w-full">
          <Image src={imageURL} width={150} height={50} layout="responsive" />
        </div>
        <div className="flex justify-between items-start text-xs">
          <h3>* Only applicable to {convertCard(card)}</h3>
          <h3>
            Valid between {moment(startDate).format("LL")} to{" "}
            {moment(endDate).format("LL")}{" "}
          </h3>
        </div>
        <h3 className="leading-relaxed">{description}</h3>
        <div className="w-1/4">
          <button
            className="inline-flex justify-center px-4 py-2 text-sm font-medium text-white bg-indigo-500 border border-transparent rounded-md hover:bg-indigo-600"
            onClick={close}
          >
            Okay
          </button>
        </div>
      </div>
    </div>
  );
};

export default CampaignModal;
