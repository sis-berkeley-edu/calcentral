import React from 'react';
import { parseISO, format } from 'date-fns';
import styles from './ServiceAlert.module.scss';

import { propTypes } from './serviceAlert.module.js';

export default function ServiceAlert({ title, body, publication_date }) {
  let formatted_date = '';

  try {
    formatted_date = format(parseISO(publication_date), 'MMM dd');
  } catch (err) {
    formatted_date = 'Date';
  }

  return (
    <div className={styles.splashCard}>
      <div className={styles.newsLabel}>CalCentral News</div>
      <div className={styles.alert}>
        <div className={styles.date}>{formatted_date}</div>
        <div className={styles.content}>
          <h2 className={styles.title}>{title}</h2>
          <div
            className={styles.body}
            dangerouslySetInnerHTML={{ __html: body }}
          />
        </div>
      </div>
    </div>
  );
}

ServiceAlert.propTypes = propTypes;
