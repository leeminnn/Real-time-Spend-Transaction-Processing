import React from "react";
import CountUp from "react-countup";
import { Card, CardBody } from "@windmill/react-ui";

const InfoCard = ({ title, value, dollar, children: icon }) => {
  return (
    <Card>
      <CardBody className="flex items-center">
        {icon}
        <div>
          <p className="mb-2 text-sm font-medium text-gray-600">{title}</p>
          {dollar && "$"}{" "}
          <CountUp
            formattingFn={(value) => value.toLocaleString()}
            duration={1}
            decimals={2}
            decimal=","
            end={value}
            className="text-lg font-semibold text-gray-700"
          />
        </div>
      </CardBody>
    </Card>
  );
};

export default InfoCard;
