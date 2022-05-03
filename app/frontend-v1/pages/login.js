import React from "react";
import Head from "next/head";
import LoginForm from "../components/LoginForm";
import TypeAnimation from "react-type-animation";

const Login = () => {
  return (
    <>
      <Head>
        <title>Ascenda Rewards</title>
      </Head>

      <div className="min-h-screen">
        <img
          src="https://images.pexels.com/photos/3747463/pexels-photo-3747463.jpeg?auto=compress&amp;cs=tinysrgb&amp;dpr=2&amp;h=750&amp;w=1260"
          className="absolute inset-0 object-cover w-full h-screen"
          alt=""
        />
        <div className="bg-gray-900 bg-opacity-75 min-h-screen relative">
          <div className="px-4 mx-auto sm:max-w-xl md:max-w-full lg:max-w-screen-xl md:px-24 lg:px-2">
            <div className="flex flex-col items-center justify-between xl:flex-row min-h-screen">
              <div className="w-full max-w-xl mb-12 xl:mb-0 xl:pr-16 xl:w-7/12">
                <TypeAnimation
                  className="max-w-xl mb-6 font-sans text-2xl font-bold tracking-loose text-white sm:text-5xl"
                  wrapper="h2"
                  cursor={true}
                  sequence={["Welcome to Ascenda Loyalty", 1000]}
                ></TypeAnimation>
                <p className="max-w-xl mb-4 text-base text-gray-400 md:text-lg">
                  We provide a platform for you to check your transaction
                  history and points earned at one glance. View all our
                  available campaigns to earn more rewards with us!
                </p>
              </div>
              <div className="w-full max-w-2xl xl:px-8 xl:w-1/2">
                <div className="bg-white rounded-lg shadow-xl p-7 sm:px-12 py-20">
                  <LoginForm />
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </>
  );
};

export default Login;
