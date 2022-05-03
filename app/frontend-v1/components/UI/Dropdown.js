import { Fragment, useEffect } from "react";
import { Listbox, Transition } from "@headlessui/react";
import { AiOutlineCheck } from "react-icons/ai";
import { HiOutlineSelector } from "react-icons/hi";
import { useRecoilState, useRecoilValue } from "recoil";
import { currCardState, allCardsState } from "../../atoms/card";

const Dropdown = () => {
  const allCards = useRecoilValue(allCardsState);
  const [card, setCard] = useRecoilState(currCardState);

  const allUserCards = [];

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

  useEffect(() => {
    if (allCards.length > 0) {
      setCard(getCardName(allCards[0]["cardType"]));
    }
  }, [allCards, setCard]);

  if (allCards.length > 0) {
    allCards.forEach((card) => {
      allUserCards.push(getCardName(card.cardType));
    });
  }

  return (
    <div className="w-72 relative z-30 cursor-pointer">
      <Listbox value={card} onChange={setCard}>
        <div className="relative mt-1">
          <Listbox.Button className="relative w-full py-2 pl-3 pr-10 text-left bg-white rounded-lg shadow-md cursor-default focus:outline-none focus-visible:ring-2 focus-visible:ring-opacity-75 focus-visible:ring-white focus-visible:ring-offset-indigo-300 focus-visible:ring-offset-2 focus-visible:border-indigo-500 sm:text-sm">
            <span className="block truncate">{card}</span>
            <span className="absolute inset-y-0 right-0 flex items-center pr-2 pointer-events-none">
              <HiOutlineSelector
                className="w-5 h-5 text-gray-400"
                aria-hidden="true"
              />
            </span>
          </Listbox.Button>
          <Transition
            as={Fragment}
            leave="transition ease-in duration-100"
            leaveFrom="opacity-100"
            leaveTo="opacity-0"
          >
            <Listbox.Options className="absolute w-full py-1 mt-1 overflow-auto text-base bg-white rounded-md shadow-lg max-h-60 ring-1 ring-black ring-opacity-5 focus:outline-none sm:text-sm">
              {allUserCards.map((card, cardIdx) => (
                <Listbox.Option
                  key={cardIdx}
                  className={({ active }) =>
                    `${
                      active ? "text-indigo-900 bg-indigo-100" : "text-gray-900"
                    }
                          cursor-default select-none relative py-2 pl-10 pr-4`
                  }
                  value={card}
                >
                  {({ selected, active }) => (
                    <>
                      <span
                        className={`${
                          selected ? "font-medium" : "font-normal"
                        } block truncate`}
                      >
                        {card}
                      </span>
                      {selected ? (
                        <span
                          className={`${
                            active ? "text-indigo-600" : "text-indigo-600"
                          }
                                absolute inset-y-0 left-0 flex items-center pl-3`}
                        >
                          <AiOutlineCheck
                            className="w-5 h-5"
                            aria-hidden="true"
                          />
                        </span>
                      ) : null}
                    </>
                  )}
                </Listbox.Option>
              ))}
            </Listbox.Options>
          </Transition>
        </div>
      </Listbox>
    </div>
  );
};

export default Dropdown;
