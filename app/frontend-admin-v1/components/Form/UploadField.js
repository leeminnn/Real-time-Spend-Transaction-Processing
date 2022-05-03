import React from "react";
import { useField, useFormikContext } from "formik";
import axios from "axios";

export const UploadField = ({ ...props }) => {
  const { setFieldValue } = useFormikContext();
  const [field] = useField(props);

  const uploadImage = async (event) => {
    const formData = new FormData();
    formData.append("file", event.target.files[0]);

    try {
      const res = await axios.post("https://api.itsag1t5.com/campaign/uploadfile", formData);
      console.log(res)
      setFieldValue("imageURL", res.data);
    } catch (err) {
      console.error(err);
    }
  };

  return (
    <input
      {...field}
      {...props}
      id="imageURL"
      type="file"
      accept="image/*"
      className="w-full text-sm text-slate-500 file:mr-4 file:py-2 file:px-4 file:rounded-full file:border-0 file:text-sm file:font-semibold file:bg-slate-500 file:text-white hover:file:bg-slate-600 focus:ring-0 file:cursor-pointer text-"
      value={undefined}
      onChange={(event) => {
        uploadImage(event);
      }}
    />
  );
};

export default UploadField;
