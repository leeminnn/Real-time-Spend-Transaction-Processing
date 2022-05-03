import React, { useState, useEffect } from "react";
import Image from "next/image";
import Visa from "../../public/assets/visa.png";
import { useRecoilValue } from "recoil";
import { allCardsState, currCardState } from "../../atoms/card";
import { getCookie } from "cookies-next";

const CreditCard = () => {
  const allCards = useRecoilValue(allCardsState);
  const currCard = useRecoilValue(currCardState);

  const nameCookie = getCookie("name");

  const cardDetails = [];

  const getCardName = (card) => {
    switch (card) {
      case "scis_shopping":
        return "SCIS Shopping Card";
      case "scis_premium":
        return "SCIS PremiumMiles Card";
      case "scis_platinum":
        return "SCIS PlatinumMiles Card";
      case "scis_freedom":
        return "SCIS Freedom Card";
      default:
        return "";
    }
  };

  const getCardColor = (card) => {
    switch (card) {
      case "scis_shopping":
        return "bg-gradient-to-l from-blue-400 to-blue-800";
      case "scis_premium":
        return "bg-gradient-to-r from-red-400 to-red-600";
      case "scis_platinum":
        return "bg-gradient-to-r from-gray-600 to-black";
      case "scis_freedom":
        return "bg-gradient-to-r from-pink-400 to-pink-600";
      default:
        return "";
    }
  };

  if (allCards.length > 0) {
    allCards.forEach((card) => {
      cardDetails.push({
        card: getCardName(card.cardType),
        color: getCardColor(card.cardType),
        cardNum: card.ccLastFour,
      });
    });
  }

  const selectedCard = cardDetails.find(({ card }) => card === currCard);

  return (
    <div className="flex flex-col space-y-8 w-full max-w-xl">
      {selectedCard && (
        <div
          className={`${selectedCard.color} text-white h-56 w-96 p-6 rounded-xl shadow-md transition-transform transform hover:scale-105 hover:shadow-2x`}
        >
          <div className="h-full flex flex-col justify-between">
            <div className="flex items-start justify-between space-x-4">
              <div className=" text-xl font-semibold tracking-tigh">
                {selectedCard.card.substring(
                  0,
                  selectedCard.card.lastIndexOf(" ")
                )}
              </div>

              <div className="inline-flex flex-col items-center justify-center w-12 pt-1">
                <Image src={Visa} alt="Visa logo" />
              </div>
            </div>

            <div className="inline-block w-12 h-8 bg-gradient-to-tl from-yellow-200 to-yellow-100 rounded-md shadow-inner overflow-hidden">
              <div className="relative w-full h-full grid grid-cols-2 gap-1">
                <div className="absolute border border-gray-900 rounded w-4 h-6 left-4 top-1"></div>
                <div className="border-b border-r border-gray-900 rounded-br"></div>
                <div className="border-b border-l border-gray-900 rounded-bl"></div>
                <div className=""></div>
                <div className=""></div>
                <div className="border-t border-r border-gray-900 rounded-tr"></div>
                <div className="border-t border-l border-gray-900 rounded-tl"></div>
              </div>
            </div>

            <div className="text-lg font-semibold tracking-wide">
              **** **** **** {selectedCard.cardNum}
            </div>

            <div className="flex justify-between">
              <div className="font-semibold flex items-end">{nameCookie}</div>
              <div className="text-xs flex flex-col items-end font-semibold tracking-wide">
                <div>Valid Thru</div>
                <div>08/25</div>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default CreditCard;
