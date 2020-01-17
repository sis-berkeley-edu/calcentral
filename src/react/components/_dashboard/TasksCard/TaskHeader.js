import React from 'react';
import PropTypes from 'prop-types';

import styles from './TaskHeader.module.scss';

const TaskHeader = ({ children }) => {
  return <div className={styles.taskHeader}>{children}</div>;
};

TaskHeader.propTypes = {
  children: PropTypes.node,
  isOverdue: PropTypes.bool,
};

export default TaskHeader;
