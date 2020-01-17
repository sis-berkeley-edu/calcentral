import React, { useContext } from 'react';
import PropTypes from 'prop-types';
import ComparisonRow from './ComparisonRow';
import formatCurrency from 'functions/formatCurrency';

import SelectedDateContext from './SelectedDateContext';

import './AwardComparison.scss';

const DollarComparisonRow = ({ description, current, snapshot }) => {
  const { selectedDate: selectedDate } = useContext(SelectedDateContext);
  const formattedCurrentValue =
    current || current === 0 ? formatCurrency(current) : 'N/A';
  const formattedSnapshotValue =
    snapshot || snapshot === 0
      ? formatCurrency(snapshot)
      : selectedDate === 'X'
      ? null
      : 'N/A';

  // console.log(snapshot);

  return (
    <ComparisonRow
      description={description}
      current={formattedCurrentValue}
      snapshot={formattedSnapshotValue}
    />
  );
};

DollarComparisonRow.displayName = 'AwardComparisonDollarComparisonRow';
DollarComparisonRow.propTypes = {
  description: PropTypes.string.isRequired,
  current: PropTypes.number,
  snapshot: PropTypes.number,
};

export default DollarComparisonRow;
