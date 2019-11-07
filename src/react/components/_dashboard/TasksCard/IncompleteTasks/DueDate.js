import React from 'react';
import PropTypes from 'prop-types';

import { shortDateIfCurrentYear, parseDate } from 'functions/formatDate';

const DueDate = ({ date }) => {
  if (date) {
    return <span>{shortDateIfCurrentYear(parseDate(date))}</span>;
  }

  return null;
};

DueDate.propTypes = {
  date: PropTypes.string,
};

export default DueDate;
