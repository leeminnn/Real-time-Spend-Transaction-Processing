import { atom } from "recoil";

export const allCardsState = atom({
  key: "allCardsState",
  default: []
});

export const currCardState = atom({
  key: "currCardState",
  default: ""
})