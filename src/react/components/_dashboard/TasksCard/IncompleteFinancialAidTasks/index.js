import React from 'react';
import PropTypes from 'prop-types';

import AidYear from './AidYearTasks';
import Category from '../Category';

function IncompleteFinancialAidTasks({ aidYears }) {
  return (
    <Category>
      {aidYears.map(aidYear => (
        <div key={aidYear.year}>
          <AidYear aidYear={aidYear} />
        </div>
      ))}
    </Category>
  );
}

IncompleteFinancialAidTasks.propTypes = {
  aidYears: PropTypes.array,
};

export default IncompleteFinancialAidTasks;
