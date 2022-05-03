import React from "react";
import Link from "next/link";
import { useRouter } from "next/router";
import { BiHome, BiUserCircle } from "react-icons/bi";
import { FaRegMoneyBillAlt } from "react-icons/fa";
import { FiLogOut } from "react-icons/fi";
import { getCookie, removeCookies } from "cookies-next";

const Sidebar = () => {
  const router = useRouter();
  const nameCookie = getCookie("name")

  const logoutHandler = () => {
    removeCookies("JWT");
    removeCookies("name");
    router.push("/login")
  }

  return (
    <div className="min-h-screen flex flex-row">
      <div className="flex flex-col w-56 bg-white rounded-r-3xl overflow-hidden pl-6">
        <div className="flex justify-start pt-6 items-center">
          <span className="text-xl font-semibold text-indigo-600">Ascenda</span>
        </div>
        <ul className="flex flex-col pt-8 space-y-6">
          <li>
            <Link href="/" passHref className="flex flex-row items-center h-12">
              <div
                className={`${
                  router.pathname === "/"
                    ? "text-gray-900"
                    : "transform hover:translate-x-2 transition-transform ease-in duration-200 text-gray-600 hover:text-gray-900"
                } flex cursor-pointer`}
              >
                <span className="inline-flex items-center justify-center">
                  <BiHome size={20} className="font-bold" />
                </span>
                <span className="text-sm font-semibold flex items-center pl-4">
                  Home
                </span>
              </div>
            </Link>
          </li>
          <li>
            <Link
              href="/product"
              passHref
              className="flex flex-row items-center h-12"
            >
              <div className="flex transform hover:translate-x-2 transition-transform ease-in duration-200 text-gray-600 hover:text-gray-900 cursor-pointer">
                <span className="inline-flex items-center justify-center">
                  <FaRegMoneyBillAlt size={20} className="font-bold" />
                </span>
                <span className="text-sm font-semibold flex items-center pl-4">
                  Transactions
                </span>
              </div>
            </Link>
          </li>
        </ul>
        <div className="flex flex-col h-full py-6 justify-end">
          <div className=" flex justify-between items-center w-full">
            <div className="flex justify-center items-center space-x-2">
              <BiUserCircle size={30} />
              <div className="flex justify-start flex-col items-start mr-4">
                <p className="font-medium text-xs text-gray-500">{nameCookie}</p>
                <p className="font-medium text-xs text-gray-500">1306752</p>
              </div>
            </div>
            <FiLogOut size={22} className="mr-8" onClick={logoutHandler} />
          </div>
        </div>
      </div>
    </div>
  );
};

export default Sidebar;
