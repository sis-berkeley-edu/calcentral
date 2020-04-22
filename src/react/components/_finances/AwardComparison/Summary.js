import React, { useEffect, useState } from 'react';
import PropTypes from 'prop-types';
import SectionHeader from './SectionHeader';
import DollarComparisonRow from './DollarComparisonRow';
import './AwardComparison.scss';

import aidYearShape from './aidYearShape';

const countTheChanges = (current, snapshot) => {
  if (!Object.keys(snapshot).length) {
    return 0;
  }

  const { awards: { total: currentAwardsTotal = 0 } = {} } = current || {};
  const { awards: { total: snapshotAwardsTotal = 0 } = {} } = snapshot || {};
  const { cost: { total: currentCostTotal = 0 } = {} } = current || {};
  const { cost: { total: snapshotCostTotal = 0 } = {} } = snapshot || {};

  let differencesCount = 0;
  currentAwardsTotal !== snapshotAwardsTotal ? differencesCount++ : null;
  currentCostTotal !== snapshotCostTotal ? differencesCount++ : null;

  return differencesCount;
};

const ifLoaded = (dataObj, callback) =>
  dataObj && dataObj.loaded ? callback() : null;

const Summary = ({
  expanded,
  onExpand,
  setExpand,
  aidYearData,
  aidYearSnapshot,
}) => {
  const [numberOfChanges, setNumberOfChanges] = useState(0);

  useEffect(() => {
    if (aidYearSnapshot) {
      setNumberOfChanges(
        countTheChanges(
          aidYearData.currentComparisonData,
          aidYearSnapshot ? aidYearSnapshot : null
        )
      );
    }
  }, [aidYearSnapshot]);

  return (
    <div>
      <div className="clickable" onClick={() => onExpand(setExpand, expanded)}>
        <SectionHeader
          expanded={expanded}
          label="Summary"
          numberOfChanges={numberOfChanges}
        />
      </div>
      {expanded ? (
        <div>
          <div className="container">
            <table>
              <thead>
                <tr>
                  <th scope="col">Description</th>
                  <th scope="col">Prior Value</th>
                  <th scope="col">Current Value</th>
                </tr>
              </thead>
              <tbody>
                <DollarComparisonRow
                  description="Total Awards"
                  current={aidYearData.currentComparisonData.awards.total}
                  snapshot={ifLoaded(
                    aidYearSnapshot,
                    () => aidYearSnapshot.awards.total
                  )}
                />
                <DollarComparisonRow
                  description="Estimated Cost of Attendance"
                  current={aidYearData.currentComparisonData.cost.total}
                  snapshot={ifLoaded(
                    aidYearSnapshot,
                    () => aidYearSnapshot.cost.total
                  )}
                />
              </tbody>
            </table>
          </div>
        </div>
      ) : (
        <hr />
      )}
    </div>
  );
};

Summary.displayName = 'AwardComparisonSummary';
Summary.propTypes = {
  expanded: PropTypes.bool.isRequired,
  onExpand: PropTypes.func.isRequired,
  setExpand: PropTypes.func.isRequired,
  aidYearData: PropTypes.object.isRequired,
  aidYearSnapshot: aidYearShape,
};

export default Summary;
