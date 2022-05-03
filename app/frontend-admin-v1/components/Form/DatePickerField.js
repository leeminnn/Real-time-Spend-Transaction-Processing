import React, { useState } from "react";
import { useField, useFormikContext } from "formik";
import DatePicker from "react-datepicker";
import moment from "moment";

export const DatePickerField = ({ ...props }) => {
  const [startDate, setStartDate] = useState();
  const { setFieldValue } = useFormikContext();
  const [field] = useField(props);

  function afterChange(e) {
    const ISOTime = moment(e).toISOString();
    setFieldValue(field.name, ISOTime);
    setStartDate(e);
  }

  return (
    <DatePicker
      {...field}
      {...props}
      className="p-1 focus:outline-none -ml-1 border-b-2 border-gray-300 w-full text-sm"
      selected={startDate}
      value={startDate}
      dateFormat="dd/MM/yyyy"
      onChange={(date) => {
        afterChange(date);
      }}
    />
  );
};

export default DatePickerField;
