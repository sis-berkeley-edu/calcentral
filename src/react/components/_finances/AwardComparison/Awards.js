import React, { Fragment, useEffect, useState } from 'react';
import PropTypes from 'prop-types';

import SectionHeader from './SectionHeader';
import DollarComparisonRow from './DollarComparisonRow';
import aidYearShape from './aidYearShape';
import './AwardComparison.scss';

const snapshotValueForDescription = (snapshot, description) => {
  const { awards: { awardTypes = [] } = {} } = snapshot || {};
  const mergedItems = [];
  awardTypes.map(awardType => {
    awardType.items.map(item => mergedItems.push(item));
  });
  const found = mergedItems.find(item => item.description === description);
  return !!found || found === 0 ? found.value : null;
};

const itemsInOneArrayButNotTheOther = (current, snapshot) => {
  const { awards: { awardTypes: currentAwardTypes = [] } = {} } = current || {};
  const mergedCurrentItems = [];
  currentAwardTypes.map(currentAwardType => {
    currentAwardType.items.map(item => mergedCurrentItems.push(item));
  });

  const { awards: { awardTypes: snapshotAwardTypes = [] } = {} } =
    snapshot || {};
  const mergedSnapshotItems = [];
  snapshotAwardTypes.map(snapshotAwardType => {
    snapshotAwardType.items.map(item => mergedSnapshotItems.push(item));
  });
  const currentSet = new Set(mergedCurrentItems.map(item => item.description));
  const snapshotSet = new Set(
    mergedSnapshotItems.map(item => item.description)
  );
  const difference = new Set([...snapshotSet].filter(x => !currentSet.has(x)));

  return Array.from(difference);
};

const comparer = otherArray => {
  return function(current) {
    return (
      otherArray.filter(function(other) {
        return (
          other.description == current.description &&
          other.value == current.value
        );
      }).length == 0
    );
  };
};

const countTheChanges = (current, snapshot) => {
  const { awards: { awardTypes: currentAwardTypes = [] } = {} } = current || {};
  const mergedCurrentItems = [];
  currentAwardTypes.map(currentAwardType => {
    currentAwardType.items.map(item => mergedCurrentItems.push(item));
  });

  const { awards: { awardTypes: snapshotAwardTypes = [] } = {} } =
    snapshot || {};
  const mergedSnapshotItems = [];
  snapshotAwardTypes.map(snapshotAwardType => {
    snapshotAwardType.items.map(item => mergedSnapshotItems.push(item));
  });

  if (mergedSnapshotItems.length === 0) {
    return 0;
  }

  // identify current items that are different or not in the snapshot
  const onlyInA = mergedCurrentItems.filter(comparer(mergedSnapshotItems));
  const onlyInB = itemsInOneArrayButNotTheOther(
    mergedCurrentItems,
    mergedSnapshotItems
  ).filter(comparer(mergedCurrentItems));

  const currentVsSnapshot = onlyInA.concat(onlyInB);

  // identify snapshot items that are different or not in the current
  const onlyInA2 = mergedSnapshotItems.filter(comparer(mergedCurrentItems));
  const onlyInB2 = itemsInOneArrayButNotTheOther(
    mergedSnapshotItems,
    mergedCurrentItems
  ).filter(comparer(mergedSnapshotItems));

  const snapshotVsCurrent = onlyInB2.concat(onlyInA2);

  // the following takes the two sets of differences, combines them
  // and removes duplicates (remember, Sets contain unique values)
  const combined = new Set(
    currentVsSnapshot.concat(snapshotVsCurrent).map(item => item.description)
  );

  return combined.size;
};

const ifLoaded = (dataObj, callback) =>
  dataObj && dataObj.loaded ? callback() : null;

const Awards = ({
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
          label="Awards"
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
                {aidYearData.currentComparisonData.awards.awardTypes.map(
                  awardType => (
                    <Fragment key={awardType.type}>
                      <>
                        <tr className="typeRow">
                          <th className="typeTitle" scope="row">
                            {awardType.description}
                          </th>
                          <td></td>
                          <td></td>
                        </tr>
                      </>
                      <>
                        {awardType.items.map(award => (
                          <Fragment key={award.description}>
                            <DollarComparisonRow
                              description={award.description}
                              current={award.value}
                              snapshot={snapshotValueForDescription(
                                aidYearSnapshot,
                                award.description
                              )}
                            />
                          </Fragment>
                        ))}
                      </>
                    </Fragment>
                  )
                )}
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
                  description="Total Awards"
                  current={aidYearData.currentComparisonData.awards.total}
                  snapshot={ifLoaded(
                    aidYearSnapshot,
                    () => aidYearSnapshot.awards.total
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

Awards.displayName = 'Awards';
Awards.propTypes = {
  expanded: PropTypes.bool.isRequired,
  onExpand: PropTypes.func.isRequired,
  setExpand: PropTypes.func.isRequired,
  aidYearData: aidYearShape.isRequired,
  aidYearSnapshot: PropTypes.object,
};

export default Awards;
