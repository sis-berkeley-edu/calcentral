import React from 'react';
import PropTypes from 'prop-types';

import styles from './TaskTitle.module.scss';

const TaskTitle = ({ title, subtitle, overdue }) => {
  const classNames = [styles.taskTitle, overdue ? styles.overdue : null];

  return (
    <div className={classNames.join(' ')}>
      <div className={styles.title}>{title}</div>
      <div>{subtitle}</div>
    </div>
  );
};

TaskTitle.propTypes = {
  title: PropTypes.string,
  subtitle: PropTypes.node,
  overdue: PropTypes.bool,
};

TaskTitle.defaultProps = {
  overdue: false,
};

export default TaskTitle;
