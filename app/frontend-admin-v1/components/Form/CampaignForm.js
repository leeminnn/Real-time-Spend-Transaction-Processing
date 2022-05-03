import React from "react";
import DatePickerField from "./DatePickerField";
import UploadField from "./UploadField";
import { Formik, Field, Form } from "formik";
import { CgSpinner } from "react-icons/cg";
import * as Yup from "yup";
import axios from "axios";

import "react-datepicker/dist/react-datepicker.css";

const campaignSchema = Yup.object().shape({
  merchant: Yup.string().required("Merchant Name is required"),
  min: Yup.number().required("Minimum Amount is required"),
  rate: Yup.number()
    .required("Reward Rate is required")
    .min(0, "Rate must be more than 0")
    .max(100, "Cashback must not be more than 100"),
  startDate: Yup.date().required("Start Date is required"),
  endDate: Yup.date()
    .required("End Date is required")
    .when(
      "startDate",
      (startDate, schema) =>
        startDate &&
        schema.min(startDate, "End Date cannot be earlier than Start Date")
    ),
  description: Yup.string().required("Please input a description"),
  imageURL: Yup.mixed().required("Please upload an image"),
});

const CampaignForm = ({ close }) => {
  const addCampaignHandler = async (values) => {
    try {
      const res = await axios.post("https://api.itsag1t5.com/campaign/new", {
        card: values.card,
        reward: values.reward,
        merchant: values.merchant,
        min: values.min,
        rate: values.rate,
        startDate: values.startDate,
        endDate: values.endDate,
        imageURL: values.imageURL,
        description: values.description,
      });

      if (res.status === 200) {
        close();
      }
    } catch (err) {
      console.error(err);
    }
  };

  return (
    <div className="mt-6">
      <Formik
        initialValues={{
          merchant: "",
          card: "scis_shopping",
          reward: "cashback",
          min: 0,
          rate: 0,
          startDate: "",
          endDate: "",
          description: "",
          imageURL: undefined,
        }}
        validationSchema={campaignSchema}
        onSubmit={(values) => addCampaignHandler(values)}
      >
        {({ values, errors, touched, isSubmitting }) => (
          <Form>
            <div className="relative z-0 w-full mb-10 flex justify-between space-x-4">
              <div className="w-full">
                <h4 className="text-sm text-gray-500 pb-2">Card Type</h4>
                <Field
                  name="card"
                  as="select"
                  className="py-1 focus:outline-none w-full -ml-1 cursor-pointer text-indigo-600 form-select rounded-md bg-white"
                >
                  <option value="scis_shopping">SCIS Shopping Card</option>
                  <option value="scis_premium">SCIS Premium Card</option>
                  <option value="scis_platinum">SCIS Platinum Card</option>
                  <option value="scis_freedom">SCIS Freedom Card</option>
                </Field>
              </div>
              <div className="w-full">
                <h4 className="text-sm text-gray-500 pb-2">Reward Type</h4>
                <Field
                  name="reward"
                  as="select"
                  className="py-1 focus:outline-none w-full -ml-1 cursor-pointer text-indigo-600 form-select rounded-md bg-white"
                >
                  <option value="cashback">Cashback</option>
                  <option value="rewards">Reward</option>
                  <option value="platinum">Miles</option>
                </Field>
              </div>
            </div>
            <div className="relative z-0 w-full group mb-12">
              <Field type="text" name="merchant" className="input-form peer" />
              <label htmlFor="merchant" className="input-label">
                Merchant Name
              </label>
              {touched.merchant && errors.merchant && (
                <div className="text-red-600 text-sm py-2">
                  {errors.merchant}
                </div>
              )}
            </div>
            <div className="flex justify-between items-center space-x-4">
              <div className="relative z-0 w-full group mb-6">
                <Field type="number" name="rate" className="input-form peer" />
                <label htmlFor="rate" className="input-label">
                  Reward Rate (%)
                </label>
                {touched.rate && errors.rate && (
                  <div className="text-red-600 text-sm py-2">{errors.rate}</div>
                )}
              </div>
              <div className="relative z-0 w-full group mb-6">
                <Field type="number" name="min" className="input-form peer" />
                <label htmlFor="min" className="input-label">
                  Minimum Amount ($)
                </label>
                {touched.min && errors.min && (
                  <div className="text-red-600 text-sm py-2">{errors.min}</div>
                )}
              </div>
            </div>
            <div className="flex justify-between items-center space-x-4 mb-6">
              <div className="relative z-50 w-full group mb-6">
                <h4 className="text-sm text-gray-500 pb-2">Start Date</h4>
                <DatePickerField name="startDate" />
                {touched.startDate && errors.startDate && (
                  <div className="text-red-600 text-sm py-2">
                    {errors.startDate}
                  </div>
                )}
              </div>
              <div className="relative z-50 w-full group mb-6">
                <h4 className="text-sm text-gray-500 pb-2">End Date</h4>
                <DatePickerField name="endDate" />
                {touched.endDate && errors.endDate && (
                  <div className="text-red-600 text-sm py-2">
                    {errors.endDate}
                  </div>
                )}
              </div>
            </div>
            <div className="relative z-0 w-full group mb-6">
              <Field
                name="description"
                as="textarea"
                className="input-form peer p-2 bg-gray-100 rounded-md"
              />
              <label htmlFor="description" className="input-label">
                Campaign Description
              </label>
              {touched.description && errors.description && (
                <div className="text-red-600 text-sm py-2">
                  {errors.description}
                </div>
              )}
            </div>
            <div className="relative z-0 w-full group mb-6">
              <h4 className="text-sm text-gray-500 pb-3">
                Campaign Image (*.jpeg, *.png)
              </h4>
              <UploadField name="imageURL" />
              {touched.imageURL && errors.imageURL && (
                <div className="text-red-600 text-sm py-2">
                  {errors.imageURL}
                </div>
              )}
              {values.imageURL && (
                <div className="text-green-600 text-sm py-2">
                  Image successfully uploaded
                </div>
              )}
            </div>
            <div className="flex justify-end items-center">
              <button
                type="submit"
                disabled={isSubmitting || values.imageURL == undefined}
                className="inline-flex justify-center px-4 py-2 text-sm font-medium text-white bg-indigo-500 border border-transparent rounded-md hover:bg-indigo-600 disabled:bg-slate-50 disabled:text-slate-300 disabled:border-slate-200 disabled:cursor-not-allowed"
              >
                {isSubmitting ? (
                  <div className="flex items-center justify-center">
                    <CgSpinner className="inline mr-2 w-6 h-6 text-white animate-spin" />
                    <h4 className="text-sm">Adding...</h4>
                  </div>
                ) : (
                  <h4 className="text-sm">Add Campaign</h4>
                )}
              </button>
            </div>
          </Form>
        )}
      </Formik>
    </div>
  );
};

export default CampaignForm;
