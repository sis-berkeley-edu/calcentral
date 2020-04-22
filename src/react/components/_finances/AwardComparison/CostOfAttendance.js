import React, { Fragment, useEffect, useState } from 'react';
import PropTypes from 'prop-types';

import SectionHeader from './SectionHeader';
import DollarComparisonRow from './DollarComparisonRow';
import aidYearShape from './aidYearShape';
import './AwardComparison.scss';

import { countTheChanges } from './AwardComparison.module';

const snapshotValueForDescription = (snapshot, description) => {
  const { cost: { items = [] } = {} } = snapshot || {};

  const found = items.find(item => item.description === description);
  return !!found || found === 0 ? found.value : null;
};

const itemsInOneArrayButNotTheOther = (current, snapshot) => {
  const { cost: { items: snapshotItems = [] } = {} } = snapshot || {};
  const { cost: { items: currentItems = [] } = {} } = current || {};

  const currentSet = new Set(currentItems.map(item => item.description));
  const snapshotSet = new Set(snapshotItems.map(item => item.description));
  const difference = new Set([...snapshotSet].filter(x => !currentSet.has(x)));
  return Array.from(difference);
};

const ifLoaded = (dataObj, callback) =>
  dataObj && dataObj.loaded ? callback() : null;

const CostOfAttendance = ({
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
          aidYearData.currentComparisonData.cost,
          aidYearSnapshot ? aidYearSnapshot.cost : null
        )
      );
    }
  }, [aidYearSnapshot]);

  return (
    <div>
      <div className="clickable" onClick={() => onExpand(setExpand, expanded)}>
        <SectionHeader
          expanded={expanded}
          label="Estimated Cost of Attendance"
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
                {aidYearData.currentComparisonData.cost.items.map(item => (
                  <Fragment key={item.description}>
                    <DollarComparisonRow
                      description={item.description}
                      current={item.value}
                      snapshot={snapshotValueForDescription(
                        aidYearSnapshot,
                        item.description
                      )}
                    />
                  </Fragment>
                ))}
                {aidYearSnapshot
                  ? itemsInOneArrayButNotTheOther(
                      aidYearData.currentComparisonData,
                      aidYearSnapshot ? aidYearSnapshot : null
                    ).map(item => (
                      <Fragment key={item}>
                        <DollarComparisonRow
                          description={item}
                          current={null}
                          snapshot={snapshotValueForDescription(
                            aidYearSnapshot,
                            item
                          )}
                        />
                      </Fragment>
                    ))
                  : null}
              </tbody>
              <tfoot>
                <DollarComparisonRow
                  description="Estimated Cost of Attendance"
                  current={aidYearData.currentComparisonData.cost.total}
                  snapshot={ifLoaded(
                    aidYearSnapshot,
                    () => aidYearSnapshot.cost.total
                  )}
                />
              </tfoot>
            </table>
          </div>
        </div>
      ) : (
        <hr />
      )}
    </div>
  );
};

CostOfAttendance.displayName = 'CostOfAttendance';
CostOfAttendance.propTypes = {
  expanded: PropTypes.bool.isRequired,
  onExpand: PropTypes.func.isRequired,
  setExpand: PropTypes.func.isRequired,
  aidYearData: aidYearShape.isRequired,
  aidYearSnapshot: PropTypes.object,
};

export default CostOfAttendance;
