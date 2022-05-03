import React from "react";
import Dashboard from "../components/Dashboard";
import Sidebar from "../components/Sidebar";
import Head from "next/head";

export default function Home() {
  return (
    <>
      <Head>
        <title>Ascenda Rewards</title>
      </Head>
      <div className="flex min-h-screen">
        <div className="flex-none fixed z-10 overflow-x-hidden top-0 left-0 shadow-md">
          <Sidebar />
        </div>
        <div className="flex-1 ml-56 max-w-7xl">
          <div className="container mx-12">
            <Dashboard />
          </div>
        </div>
      </div>
    </>
  );
}
