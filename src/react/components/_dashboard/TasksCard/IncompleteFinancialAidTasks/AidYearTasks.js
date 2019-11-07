import React, { useState } from 'react';
import PropTypes from 'prop-types';

import CategoryHeader from '../IncompleteTasks/CategoryHeader';
import CategorySection from '../IncompleteTasks/CategorySection';

import styles from './AidYearTasks.module.scss';

const AidYear = ({ aidYear }) => {
  const items = aidYear.tasks;

  const [expanded, setExpanded] = useState(false);

  const itemsIncomplete = items.filter(item => item.isIncomplete);
  const itemsBeingProcessed = items.filter(item => item.isBeingProcessed);

  const incompleteCount = itemsIncomplete.length;
  const inProcessCount = itemsBeingProcessed.length;

  return (
    <div className={`${styles.aidYear}`}>
      <CategoryHeader
        title="Financial Aid Tasks"
        aidYear={items[0].aidYearName}
        incompleteCount={incompleteCount}
        inProcessCount={inProcessCount}
        expanded={expanded}
        setExpanded={setExpanded}
      />

      {expanded && (
        <div className={styles.categorySections}>
          {incompleteCount > 0 && (
            <CategorySection
              items={itemsIncomplete}
              categorySection="incomplete"
              columns={['Title']}
            />
          )}

          {inProcessCount > 0 && (
            <CategorySection
              items={itemsBeingProcessed}
              categorySection="beingProcessed"
              columns={['Title']}
            />
          )}
        </div>
      )}
    </div>
  );
};

AidYear.propTypes = {
  aidYear: PropTypes.object,
};

export default AidYear;
