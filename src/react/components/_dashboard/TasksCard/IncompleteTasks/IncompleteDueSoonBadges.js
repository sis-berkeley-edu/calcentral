import React from 'react';
import PropTypes from 'prop-types';

import styles from './IncompleteDueSoonBadges.module.scss';
import { isDueWithinWeek } from '../tasks.module';

const DueWithinWeekBadge = ({ count }) => {
  if (count > 0) {
    return (
      <span style={{ color: `#f79400`, padding: `3px` }}>
        <i
          className="fa fa-exclamation-triangle cc-icon-gold"
          aria-hidden="true"
        ></i>{' '}
        {count} due within 1 week
      </span>
    );
  }

  return null;
};

DueWithinWeekBadge.propTypes = {
  count: PropTypes.number,
};

const IncompleteBadge = ({ count }) => {
  if (count > 0) {
    const classNames = `cc-widget-task-section-incomplete-count ${styles.badge}`;

    return (
      <span className={classNames}>
        <i className="fa fa-bell" aria-hidden="true"></i> {count} incomplete
      </span>
    );
  }

  return null;
};

IncompleteBadge.propTypes = {
  count: PropTypes.number,
};

const IncompleteDueSoonBadges = ({ incomplete, tasks }) => {
  const notBCourses = tasks[0].displayCategory !== 'bCourses';
  const dueWithinWeek = tasks.filter(isDueWithinWeek).length;

  if (incomplete > 0 || dueWithinWeek > 0) {
    return (
      <div>
        <IncompleteBadge count={incomplete} />
        {notBCourses && <DueWithinWeekBadge count={dueWithinWeek} />}
      </div>
    );
  }

  return null;
};

IncompleteDueSoonBadges.propTypes = {
  incomplete: PropTypes.number,
  tasks: PropTypes.array,
};

export default IncompleteDueSoonBadges;
