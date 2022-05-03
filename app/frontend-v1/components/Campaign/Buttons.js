import React from "react";
import styles from "./Campaign.module.css";
import { FaArrowLeft, FaArrowRight } from "react-icons/fa";

export const DotButton = ({ selected, onClick }) => (
  <button
    className={`${styles.embla__dot} ${
      selected ? `${styles.is_selected}` : ""
    }`}
    type="button"
    onClick={onClick}
  />
);

export const PrevButton = ({ enabled, onClick }) => (
  <button
    className={`${styles.embla__button} ${styles.embla__button__prev}`}
    onClick={onClick}
    disabled={!enabled}
  >
    <FaArrowLeft size={35} />
  </button>
);

export const NextButton = ({ enabled, onClick }) => (
  <button
    className={`${styles.embla__button} ${styles.embla__button__next}`}
    onClick={onClick}
    disabled={!enabled}
  >
    <FaArrowRight size={35} />
  </button>
);
