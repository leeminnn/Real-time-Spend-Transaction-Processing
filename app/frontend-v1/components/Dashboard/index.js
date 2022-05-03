import React, { useState, useEffect } from "react";
import InfoCard from "../UI/InfoCard";
import Dropdown from "../UI/Dropdown";
import CreditCard from "../CreditCard";
import TransactionTable from "./TransactionTable";
import Campaign from "../Campaign";
import Image from "next/image";
import moment from "moment";
import { useRecoilState } from "recoil";
import { currCardState, allCardsState } from "../../atoms/card";
import { Card, CardBody } from "@windmill/react-ui";
import { getCookie, getCookies } from "cookies-next";
import axios from "axios";
import {
  FaMoneyBillWave,
  FaPlaneDeparture,
  FaShoppingCart,
} from "react-icons/fa";

const points = {
  shopping: {
    cashback: 124.61,
    points: 23000,
    miles: 51000,
    color: "bg-gradient-to-l from-blue-400 to-blue-800",
    number: "8200",
  },
  premium: {
    cashback: 1512.33,
    points: 117000,
    miles: 32100,
    color: "bg-gradient-to-r from-red-400 to-red-600",
    number: "1462",
  },
  platinum: {
    cashback: 1124.61,
    points: 29220,
    miles: 211070,
    color: "bg-gradient-to-r from-gray-600 to-black",
    number: "2322",
  },
  freedom: {
    cashback: 94.22,
    points: 11000,
    miles: 10000,
    color: "bg-gradient-to-r from-pink-400 to-pink-600",
    number: "2682",
  },
};

const Dashboard = () => {
  const cookies = getCookies("JWT");
  const nameCookie = getCookie("name");
  const [rewards, setRewards] = useState();
  const [cashback, setCashback] = useState(0);
  const [points, setPoints] = useState(0);
  const [miles, setMiles] = useState(0);
  const [, setAllCards] = useRecoilState(allCardsState);

  const cardUrl = "https://api.itsag1t5.com/users/cards";
  const rewardUrl = "https://api.itsag1t5.com/users/rewards";
  const headers = {
    "Content-Type": "application/json",
    Authorization: `Bearer ${cookies.JWT}`,
  };

  useEffect(() => {
    axios
      .get(cardUrl, { headers })
      .then((res) => {
        setAllCards(res.data);
      })
      .catch((err) => {
        console.log(err);
      });

    axios
      .get(rewardUrl, { headers })
      .then((res) => {
        setRewards(res.data);
      })
      .catch((err) => {
        console.log(err);
      });
  }, []);

  useEffect(() => {
    if (rewards) {
      rewards.forEach((reward) => {
        switch (reward.rewardType) {
          case "cashback":
            setCashback(reward.balance);
            break;
          case "points":
            setPoints(reward.balance);
            break;
          case "miles":
            setMiles(reward.balance);
            break;
          default:
            break;
        }
      });
    }
  }, [rewards]);

  return (
    <>
      <Card className="bg-indigo-50 my-12">
        <CardBody className="flex justify-between items-center mx-8">
          <div className="">
            <h1 className="text-2xl font-medium text-indigo-600">
              Welcome back, {nameCookie}!
            </h1>
            <h1 className="mt-4 text-lg text-indigo-600">
              Check out the latest campaigns available right now! 🎉
            </h1>
          </div>
          <div>
            <Image
              src="/assets/finger.png"
              alt="finger"
              width={200}
              height={200}
            />
          </div>
        </CardBody>
      </Card>

      <Campaign />

      {/* <!-- Cards --> */}
      <div className="my-6 w-full flex justify-between items-center">
        <h1 className="text-2xl font-semibold text-gray-700 ">Dashboard</h1>
        <p className="text-xs font-semibold text-gray-400">
          Last updated as of {moment().format("lll")} (+8GMT)
        </p>
      </div>

      <Dropdown />
      {rewards && (
        <>
          <div className="flex justify-start items-center my-8">
            <CreditCard />
          </div>
          <div className="grid gap-6 mb-8 md:grid-cols-2 xl:grid-cols-3">
            <InfoCard title="Cashback" value={cashback} dollar={true}>
              <div className="flex items-center justify-center w-12 h-12 mr-4 rounded-full bg-indigo-50">
                <FaMoneyBillWave className="text-indigo-500 w-12" />
              </div>
            </InfoCard>

            <InfoCard title="Points" value={points} dollar={false}>
              <div className="flex items-center justify-center w-12 h-12 mr-4 rounded-full bg-orange-50">
                <FaShoppingCart className="text-orange-500 w-12" />
              </div>
            </InfoCard>

            <InfoCard title="Miles" value={miles} dollar={false}>
              <div className="flex items-center justify-center w-12 h-12 mr-4 rounded-full bg-green-50">
                <FaPlaneDeparture className="text-green-500 w-12" />
              </div>
            </InfoCard>
          </div>
        </>
      )}

      <TransactionTable />
    </>
  );
};

export default Dashboard;
