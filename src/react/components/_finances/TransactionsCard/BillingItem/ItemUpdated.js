import React from 'react';
import PropTypes from 'prop-types';

import { differenceInDays, distanceInWordsStrict, parseISO } from 'date-fns';

import './ItemUpdated.scss';
const ItemUpdated = ({ item }) => {
  if (item.updated_on === item.posted_on) {
    return null;
  }

  const date = parseISO(item.updated_on);
  const diff = Math.abs(differenceInDays(date, new Date()));

  if (diff === 0) {
    return <div className="ItemUpdated">Updated today</div>;
  }

  if (diff > 0 && diff <= 30) {
    const distance = distanceInWordsStrict(date, new Date(), { unit: 'd' });
    return <div className="ItemUpdated">{`Updated ${distance} ago`}</div>;
  }

  if (diff > 30) {
    return null;
  }
};
ItemUpdated.propTypes = {
  item: PropTypes.object,
};

export default ItemUpdated;
