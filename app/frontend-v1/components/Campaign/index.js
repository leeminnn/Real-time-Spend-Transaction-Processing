import React, { useState, useEffect, useCallback, useRef } from "react";
import Image from "next/image";
import { DotButton, PrevButton, NextButton } from "./Buttons";
import Autoplay from "embla-carousel-autoplay";
import useEmblaCarousel from "embla-carousel-react";
import styles from "./Campaign.module.css";
import axios from "axios";
import Popup from "./Popup";
import useSWR from "swr";

const fetcher = url => axios.get(url).then(res => res.data)

const Campaign = () => {
  const [isOpenModal, setIsOpenModal] = useState(false);

  const { data } = useSWR("https://api.itsag1t5.com/campaign/getall", fetcher, { refreshInterval: 1000 })

  const autoplay = useRef(
    Autoplay(
      { delay: 8000, stopOnInteraction: false },
      (emblaRoot) => emblaRoot.parentElement
    )
  );

  const [viewportRef, embla] = useEmblaCarousel(
    {
      loop: true,
      scrollSnap: true,
    },
    [autoplay.current]
  );
  const [prevBtnEnabled, setPrevBtnEnabled] = useState(false);
  const [nextBtnEnabled, setNextBtnEnabled] = useState(false);
  const [selectedIndex, setSelectedIndex] = useState(0);
  const [scrollSnaps, setScrollSnaps] = useState([]);

  const scrollNext = useCallback(() => {
    if (!embla) return;
    embla.scrollNext();
    autoplay.current.reset();
  }, [embla]);

  const scrollPrev = useCallback(() => {
    if (!embla) return;
    embla.scrollPrev();
    autoplay.current.reset();
  }, [embla]);

  const scrollTo = useCallback(
    (index) => embla && embla.scrollTo(index),
    [embla]
  );

  const onSelect = useCallback(() => {
    if (!embla) return;
    setSelectedIndex(embla.selectedScrollSnap());
    setPrevBtnEnabled(embla.canScrollPrev());
    setNextBtnEnabled(embla.canScrollNext());
  }, [embla]);

  useEffect(() => {
    if (!embla) return;
    onSelect();
    setScrollSnaps(embla.scrollSnapList());
    embla.on("select", onSelect);
  }, [embla, setScrollSnaps, onSelect]);

  return (
    <>
      {data && (
        <>
          <div className={styles.embla}>
            <div className={styles.embla__viewport} ref={viewportRef}>
              <div className={styles.embla__container}>
                {data.map((campaign, index) => (
                  <div className={styles.embla__slide} key={index}>
                    <div className={styles.embla__slide__inner}>
                      <Image
                        className={styles.embla__slide__img}
                        src={campaign.imageURL}
                        layout="fill"
                        priority={true}
                      />
                      <Popup data={campaign} isOpen={isOpenModal} />
                    </div>
                  </div>
                ))}
              </div>
            </div>
            <PrevButton onClick={scrollPrev} enabled={prevBtnEnabled} />
            <NextButton onClick={scrollNext} enabled={nextBtnEnabled} />
          </div>
          <div className={styles.embla__dots}>
            {scrollSnaps.map((_, index) => (
              <DotButton
                key={index}
                selected={index === selectedIndex}
                onClick={() => scrollTo(index)}
              />
            ))}
          </div>
        </>
      )}
    </>
  );
};

export default Campaign;
