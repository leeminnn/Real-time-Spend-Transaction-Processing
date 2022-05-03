import React, { useState, useEffect } from "react";
import moment from "moment";
import axios from "axios";
import { getCookies } from "cookies-next";
import { useRecoilValue } from "recoil";
import { currCardState, allCardsState } from "../../atoms/card";
import { CgSpinner } from "react-icons/cg";
import {
  TableBody,
  TableContainer,
  Table,
  TableHeader,
  TableCell,
  TableRow,
  TableFooter,
  Badge,
  Pagination,
} from "@windmill/react-ui";

const TransactionTable = () => {
  const currCard = useRecoilValue(currCardState);
  const allCards = useRecoilValue(allCardsState);
  const [cardId, setCardId] = useState("");
  const cookies = getCookies("JWT");

  const [page, setPage] = useState(1);
  const [totalResults, setTotalResults] = useState(0);
  const [data, setData] = useState([]);

  // pagination setup
  const resultsPerPage = 7;

  // pagination change control
  const onPageChange = (p) => {
    setPage(p);
  };

  const cardNaming = {
    "SCIS Shopping Card": "scis_shopping",
    "SCIS Premium Card": "scis_premium",
    "SCIS Platinum Card": "scis_platinum",
    "SCIS Freedom Card": "scis_freedom",
  };

  useEffect(() => {
    const cardType = cardNaming[currCard];
    console.log(cardType);

    const thisCard = allCards.find((card) => card.cardType === cardType);
    console.log(thisCard);
    if (thisCard !== undefined) {
      setCardId(thisCard.cardId);
    }
  }, [currCard, allCards]);

  console.log(cardId);

  useEffect(() => {
    const fetchData = async () => {
      if (cardId !== "") {
        try {
          const result = await axios.post(
            "https://api.itsag1t5.com/users/transactions",
            {
              cardId: cardId,
            },
            {
              headers: {
                Authorization: `Bearer ${cookies.JWT}`,
              },
            }
          );
          console.log(result);
          setData(result.data);
          setTotalResults(result.data.length);
        } catch (err) {
          console.error(err);
        }
      }
    };
    fetchData();
  }, [cardId]);
  
  console.log(data);

  useEffect(() => {
    if (data) {
      setData(data.slice((page - 1) * resultsPerPage, page * resultsPerPage));
    }
  }, [page]);

  return (
    <TableContainer className="mb-8">
      <Table>
        <TableHeader>
          <tr>
            <TableCell>Date</TableCell>
            <TableCell>Merchant</TableCell>
            <TableCell>Type</TableCell>
            <TableCell>Points</TableCell>
            <TableCell>Remarks</TableCell>
          </tr>
        </TableHeader>
        <TableBody>
          {data ? (
            data.map((transaction, i) => (
              <TableRow key={i}>
                <TableCell>
                  <span className="text-sm font-semibold">
                    {moment(new Date(transaction.transactionDate)).format(
                      "DD MMM YY"
                    )}
                  </span>
                </TableCell>
                <TableCell>
                  <div className="flex items-center text-sm">
                    <div>
                      <p className="font-semibold">{transaction.merchant}</p>
                    </div>
                  </div>
                </TableCell>
                <TableCell>
                  <Badge type="success">Earn</Badge>
                </TableCell>
                <TableCell>
                  <span className="text-sm font-semibold">
                    + {transaction.reward.value.toLocaleString()}
                  </span>
                </TableCell>
                <TableCell>
                  <span className="text-sm text-green-500">
                    {transaction.reward.remarks.join(" ")}
                  </span>
                </TableCell>
              </TableRow>
            ))
          ) : (
            <div className="flex justify-center items-center my-20">
              <CgSpinner className="inline mr-2 w-20 h-20 text-indigo-500 animate-spin" />
            </div>
          )}
        </TableBody>
      </Table>
      <TableFooter>
        <Pagination
          totalResults={totalResults}
          resultsPerPage={resultsPerPage}
          label="Table navigation"
          onChange={onPageChange}
        />
      </TableFooter>
    </TableContainer>
  );
};

export default TransactionTable;
