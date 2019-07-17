import React from 'react';
import PropTypes from 'prop-types';

import parseDate from 'date-fns/parse';
import { differenceInDays, distanceInWordsStrict } from 'date-fns';

import './ItemUpdated.scss';
const ItemUpdated = ({ item }) => {
  const date = parseDate(item.updated_on);
  const diff = Math.abs(differenceInDays(date, new Date()));

  if (diff === 0) {
    return (
      <div className='ItemUpdated'>Updated today</div>
    );
  }

  if (diff > 0 && diff <= 30) {
    const distance = distanceInWordsStrict(date, new Date(), { unit: 'd' });
    return (
      <div className='ItemUpdated'>{`Updated ${distance} ago`}</div>
    );
  }

  if (diff > 30) {
    return null;
  }
};
ItemUpdated.propTypes = {
  item: PropTypes.object
};

export default ItemUpdated;
