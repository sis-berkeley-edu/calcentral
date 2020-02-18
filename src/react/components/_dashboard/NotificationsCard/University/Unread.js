import React from 'react';
import PropTypes from 'prop-types';

import styles from './Unread.module.scss';

const Unread = ({ count }) => {
  if (count > 0) {
    const message =
      count === 1 ? `1 unread notification` : `${count} unread notifications`;

    return <div className={styles.banner}>{message}</div>;
  }

  return null;
};

Unread.propTypes = {
  count: PropTypes.number,
};

export default Unread;
