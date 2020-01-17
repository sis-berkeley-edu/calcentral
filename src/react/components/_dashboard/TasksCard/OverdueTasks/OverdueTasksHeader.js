import React from 'react';
import PropTypes from 'prop-types';

import styles from './OverdueTasksHeader.module.scss';

const OverdueTasksHeader = ({ children }) => {
  return (
    <div className={styles.header}>
      <h4 className={styles.title}>{children}</h4>
    </div>
  );
};

OverdueTasksHeader.propTypes = {
  children: PropTypes.node,
};

export default OverdueTasksHeader;
