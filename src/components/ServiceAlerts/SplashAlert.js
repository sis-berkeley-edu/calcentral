import React from 'react';
import { parseISO, format } from 'date-fns';

import styles from './SplashAlert.module.scss';
import { propShape } from './serviceAlert.module.js';

const formatDate = dateString => {
  try {
    return format(parseISO(dateString), 'MMM dd');
  } catch (e) {
    // No-op
  }
};

const SplashAlert = ({ serviceAlert: { title, body, publication_date } }) => (
  <div className={styles.SplashAlert}>
    <div className={styles.DateColumn}>
      <strong className={styles.date}>{formatDate(publication_date)}</strong>
    </div>
    <div style={{ flex: `5` }}>
      <div className={styles.title}>{title}</div>
      <div className={styles.body} dangerouslySetInnerHTML={{ __html: body }} />
    </div>
  </div>
);

SplashAlert.propTypes = {
  serviceAlert: propShape,
};

export default SplashAlert;
