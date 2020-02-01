import React from 'react';
import PropTypes from 'prop-types';

import { shortDateIfCurrentYear, parseDate } from 'functions/formatDate';

import { isDueWithinWeek } from '../tasks.module';

const WarningIfDueSoon = ({ date }) => {
  if (isDueWithinWeek({ dueDate: date })) {
    return (
      <i
        className="fa fa-exclamation-triangle cc-icon-gold"
        aria-hidden="true"
      ></i>
    );
  }

  return null;
};

WarningIfDueSoon.propTypes = {
  date: PropTypes.string,
};

const DueDate = ({ date }) => {
  if (date) {
    return (
      <span>
        <WarningIfDueSoon date={date} /> Due{' '}
        {shortDateIfCurrentYear(parseDate(date))}
      </span>
    );
  }

  return null;
};

DueDate.propTypes = {
  date: PropTypes.string,
};

export default DueDate;
