import React from 'react';
import PropTypes from 'prop-types';

import TransactionHistory from './TransactionHistory';
import MoreDetails from './MoreDetails';

import './ItemDetails.scss';

const ItemDetails = ({ item }) => {
  return (
    <div className="ItemDetails" onClick={(e) => e.stopPropagation()}>
      <TransactionHistory item={item} />
      <MoreDetails item={item} />
    </div>
  );
};

ItemDetails.propTypes = {
  item: PropTypes.object
};

export default ItemDetails;
