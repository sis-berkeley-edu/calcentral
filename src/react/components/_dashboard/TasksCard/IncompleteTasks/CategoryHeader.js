import React from 'react';
import PropTypes from 'prop-types';

import styles from './CategoryHeader.module.scss';

import IncompleteDueSoonBadges from './IncompleteDueSoonBadges';

import { isDueWithinWeek } from '../tasks.module';

const CategoryHeader = ({
  tasks,
  title,
  aidYear,
  incompleteCount,
  inProcessCount,
  expanded,
  setExpanded,
}) => {
  const dueWithinWeek = tasks.filter(isDueWithinWeek).length;

  return (
    <div className={styles.categoryHeader}>
      <div>
        <h4>
          {title}{' '}
          {aidYear && <span className={styles.aidYearLabel}>{aidYear}</span>}
        </h4>

        <IncompleteDueSoonBadges
          incomplete={incompleteCount}
          dueSoon={dueWithinWeek}
        />

        {inProcessCount > 0 && (
          <div className={styles.beingProcessed}>
            {inProcessCount} being processed
          </div>
        )}
      </div>

      <button
        className="cc-button cc-button-medium"
        onClick={() => setExpanded(!expanded)}
      >
        <strong>{expanded ? 'Hide' : 'View'}</strong>
      </button>
    </div>
  );
};

CategoryHeader.propTypes = {
  tasks: PropTypes.array,
  title: PropTypes.string,
  aidYear: PropTypes.string,
  incompleteCount: PropTypes.number,
  inProcessCount: PropTypes.number,
  expanded: PropTypes.bool,
  setExpanded: PropTypes.func,
};

export default CategoryHeader;
