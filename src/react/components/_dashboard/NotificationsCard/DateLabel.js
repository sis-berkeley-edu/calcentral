import React from 'react';
import PropTypes from 'prop-types';

import { format, isThisYear } from 'date-fns';
import styles from './DateLabel.module.scss';

const DateLabel = ({ date }) => (
  <div className={styles.dateLabel}>
    <span className={styles.month}>{format(date, 'MMM').toUpperCase()}</span>
    <span className={styles.day}>{format(date, 'd')}</span>

    {!isThisYear(date) && (
      <span className={styles.year}>{format(date, 'y')}</span>
    )}
  </div>
);
DateLabel.propTypes = {
  date: PropTypes.instanceOf(Date),
};

export default DateLabel;
