import React from 'react';
import PropTypes from 'prop-types';

import styles from './IncompleteBadge.module.scss';

const IncompleteBadge = ({ count }) => {
  if (count) {
    const classNames = `cc-widget-task-section-incomplete-count ${styles.badge}`;

    return (
      <div>
        <span className={classNames}>
          <i className="fa fa-bell" aria-hidden="true"></i> {count} incomplete
        </span>
      </div>
    );
  }

  return null;
};

IncompleteBadge.propTypes = {
  count: PropTypes.number,
};

export default IncompleteBadge;
