import React, { useState, useEffect, useRef } from "react";
import { useRouter } from "next/router";
import { Form, Formik, Field } from "formik";
import { FaLock } from "react-icons/fa";
import { CgSpinner } from "react-icons/cg";
import * as Yup from "yup";
import axios from "axios";
import { setCookies } from "cookies-next";

const loginSchema = Yup.object().shape({
  email: Yup.string()
    .email("Invalid email address")
    .required("Please input your email address"),
  password: Yup.string().required("Please input your password"),
});

const LoginForm = () => {
  const [loginFail, setLoginFail] = useState("");
  const timerRef = useRef(null);
  const router = useRouter();

  const handleLogin = (email, ccLastFour, setSubmitting) => {
    const url = "https://api.itsag1t5.com/auth/login";
    const data = { email: email, ccLastFour: parseInt(ccLastFour) };
    const headers = {
      "Content-Type": "application/json",
    };

    const getName = (email) => {
      return email.split("@")[0];
    };

    timerRef.current = setTimeout(() => {
      axios
        .post(url, data, { headers })
        .then((res) => {
          setCookies("JWT", res.data.jwt, {
            path: "/",
            maxAge: 3600,
            sameSite: true,
          });
          setCookies("name", getName(email), {
            path: "/",
            maxAge: 3600,
            sameSite: true,
          });
          router.push("/");
        })
        .catch((err) => {
          setLoginFail("Your email or password is incorrect");
          setSubmitting(false);
          console.log(err);
        });
    }, 1000);
  };

  useEffect(() => {
    return () => clearTimeout(timerRef.current);
  }, []);

  return (
    <>
      <div>
        <div className="flex justify-center items-center">
          <div className="w-16">
            <img src="/assets/ascenda.png" alt="Ascenda Logo" />
          </div>
        </div>
        <h2 className="my-6 text-center text-3xl font-extrabold text-gray-900">
          Sign in to your account
        </h2>
      </div>
      <Formik
        initialValues={{ email: "", password: "" }}
        validationSchema={loginSchema}
        onSubmit={(value, { setSubmitting }) =>
          handleLogin(value.email, value.password, setSubmitting)
        }
      >
        {({ values, errors, touched, isSubmitting }) => (
          <Form className="flex flex-col space-y-4">
            <div>
              <label htmlFor="email">Email address</label>
              <Field
                id="email"
                name="email"
                type="email"
                autoComplete="email"
                className="appearance-none rounded-none relative block w-full px-3 py-2 border border-gray-300 text-gray-900 rounded-t-md focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 focus:z-10 sm:text-sm"
              />
              {touched.email && errors.email && (
                <div className="text-red-600 text-sm py-2">{errors.email}</div>
              )}
            </div>
            <div>
              <label htmlFor="password">Password</label>
              <Field
                id="password"
                name="password"
                type="password"
                autoComplete="current-password"
                className="appearance-none rounded-none relative block w-full px-3 py-2 border border-gray-300 text-gray-900 rounded-b-md focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 focus:z-10 sm:text-sm"
              />
              {touched.password && errors.password && (
                <div className="text-red-600 text-sm py-2">
                  {errors.password}
                </div>
              )}

              {loginFail && (
                <div className="text-red-600 text-sm py-2">{loginFail}</div>
              )}
            </div>

            <div className="flex items-center justify-between pb-8">
              <div className="flex items-center">
                <input
                  id="remember-me"
                  name="remember-me"
                  type="checkbox"
                  className="h-4 w-4 text-indigo-600 focus:ring-indigo-500 border-gray-300 rounded"
                />
                <label
                  htmlFor="remember-me"
                  className="ml-2 block text-sm text-gray-900"
                >
                  Remember me
                </label>
              </div>

              <div className="text-sm">
                <a className="font-medium text-indigo-600 hover:text-indigo-500">
                  Forgot your password?
                </a>
              </div>
            </div>

            <div>
              <button
                type="submit"
                disabled={isSubmitting}
                className="group relative w-full flex justify-center py-2 px-4 border border-transparent text-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
              >
                <span className="absolute left-0 inset-y-0 flex items-center pl-3">
                  <FaLock
                    className="h-5 w-5 text-indigo-500 group-hover:text-indigo-400"
                    aria-hidden="true"
                  />
                </span>
                {isSubmitting ? (
                  <div className="flex items-center justify-center">
                    <CgSpinner className="inline mr-2 w-6 h-6 text-white animate-spin" />
                    <h4 className="text-sm">Signing in...</h4>
                  </div>
                ) : (
                  <h4 className="text-sm">Sign In</h4>
                )}
              </button>
            </div>
          </Form>
        )}
      </Formik>
    </>
  );
};

export default LoginForm;
