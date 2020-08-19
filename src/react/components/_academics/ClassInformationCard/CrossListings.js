import React from 'react';
import PropTypes from 'prop-types';

import styles from './CrossListings.module.scss';

export default function CrossListings({ listings = [] }) {
  if (listings.length > 1) {
    const courseCodes = listings
      .map(listing => listing.course_code)
      .join(' • ');

    return (
      <div className={styles.crossListings}>
        <h2 className={styles.title}>Cross-listed as</h2>

        <div>{courseCodes}</div>
      </div>
    );
  }

  return null;
}

CrossListings.propTypes = {
  listings: PropTypes.arrayOf(
    PropTypes.shape({
      courseCatalog: PropTypes.string,
      course_code: PropTypes.string,
      course_id: PropTypes.string,
      dept: PropTypes.string,
      dept_code: PropTypes.string,
    })
  ),
};
