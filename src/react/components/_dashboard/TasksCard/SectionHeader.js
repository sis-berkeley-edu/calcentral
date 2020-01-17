import React from 'react';
import PropTypes from 'prop-types';

import styles from './SectionHeader.module.scss';

const SectionHeader = ({ columns, leftBorder }) => {
  const classNames = [
    styles.sectionHeader,
    leftBorder ? styles.leftBorder : null,
  ].join(' ');

  return (
    <div className={classNames}>
      {columns.map(column => (
        <div key={column} className={styles.columnLabel}>
          {column}
        </div>
      ))}
    </div>
  );
};

SectionHeader.propTypes = {
  columns: PropTypes.arrayOf(PropTypes.string),
  leftBorder: PropTypes.bool,
};

export default SectionHeader;
