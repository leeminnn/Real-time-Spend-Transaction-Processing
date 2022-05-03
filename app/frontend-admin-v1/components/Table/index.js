import React from "react";
import Popup from "../UI/Popup";
import moment from "moment";
import axios from "axios";
import { CgSpinner } from "react-icons/cg";
import useSWR from "swr";

const fetcher = url => axios.get(url).then(res => res.data)

const Table = () => {
  const { data } = useSWR("https://api.itsag1t5.com/campaign/getall", fetcher, { refreshInterval: 1000 })

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
    <div className="flex flex-col">
      <div className="overflow-x-auto shadow-md sm:rounded-lg">
        <div className="inline-block min-w-full align-middle">
          <div className="overflow-hidden ">
            <table className="min-w-full divide-y divide-gray-200 table-fixed">
              <thead className="bg-gray-100">
                <tr>
                  <th
                    scope="col"
                    className="py-3 px-6 text-xs font-medium tracking-wider text-left text-gray-700 uppercase"
                  >
                    Merchant
                  </th>
                  <th
                    scope="col"
                    className="py-3 px-6 text-xs font-medium tracking-wider text-left text-gray-700 uppercase"
                  >
                    Start Date
                  </th>
                  <th
                    scope="col"
                    className="py-3 px-6 text-xs font-medium tracking-wider text-left text-gray-700 uppercase"
                  >
                    End Date
                  </th>
                  <th
                    scope="col"
                    className="py-3 px-6 text-xs font-medium tracking-wider text-left text-gray-700 uppercase"
                  >
                    Card Type
                  </th>
                  <th
                    scope="col"
                    className="py-3 px-6 text-xs font-medium tracking-wider text-left text-gray-700 uppercase"
                  >
                    Reward Type
                  </th>
                  <th
                    scope="col"
                    className="py-3 px-6 text-xs font-medium tracking-wider text-left text-gray-700 uppercase"
                  >
                    Preview
                  </th>
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-gray-200">
                {data &&
                  data.map((campaign, id) => (
                    <tr key={id} className="hover:bg-gray-100">
                      <td className="py-4 px-6 text-sm font-medium text-gray-900 whitespace-nowrap">
                        {campaign.merchant}
                      </td>
                      <td className="py-4 px-6 text-sm font-medium text-gray-900 whitespace-nowrap">
                        {moment(campaign.startDate).format("LL")}
                      </td>
                      <td className="py-4 px-6 text-sm font-medium text-gray-900 whitespace-nowrap">
                        {moment(campaign.endDate).format("LL")}
                      </td>
                      <td className="py-4 px-6 text-sm font-medium text-gray-500 whitespace-nowrap">
                        {convertCard(campaign.card)}
                      </td>
                      <td className="py-4 px-6 text-sm font-medium text-gray-900 whitespace-nowrap capitalize">
                        {campaign.reward}
                      </td>
                      <td className="py-4 pl-6 text-sm font-medium text-gray-900 whitespace-nowrap capitalize">
                        <Popup
                          type="more"
                          data={campaign}
                        />
                      </td>
                    </tr>
                  ))}
              </tbody>
            </table>
          </div>
        </div>
      </div>
      {!data && (
        <div className="flex justify-center items-center my-20">
          <CgSpinner className="inline mr-2 w-20 h-20 text-indigo-500 animate-spin" />
        </div>
      )}
    </div>
  );
};

export default Table;
