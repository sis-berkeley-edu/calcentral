import React, { useContext } from 'react';
import PropTypes from 'prop-types';

import SelectedDateContext from './SelectedDateContext';
import OrangeChangedIcon from '../../Icon/OrangeChangedIcon';

import './AwardComparison.scss';

const SubvaluesComparisonRow = ({ description, current, snapshot }) => {
  const { selectedDate: selectedDate } = useContext(SelectedDateContext);

  const mergedData = (current, snapshot) => {
    const currentTerms = current ? current.map(item => item.term) : null;
    const snapshotTerms = snapshot ? snapshot.map(item => item.term) : null;

    const combinedTerms = snapshotTerms
      ? new Set(currentTerms.concat(snapshotTerms))
      : new Set(currentTerms);

    return Array.from(combinedTerms).map(term => {
      return {
        term: term,
        currentValue:
          current && current.find(item => item.term === term)
            ? current.find(item => item.term === term).value
            : 'N/A',
        snapshotValue:
          selectedDate === 'X'
            ? null
            : snapshot && snapshot.find(item => item.term === term)
            ? snapshot.find(item => item.term === term).value
            : 'N/A',
      };
    });
  };

  const cellStyle = (x, y) => {
    return x === y || (x === null && selectedDate === 'X')
      ? 'subvalueData'
      : 'subvalueData valueCellChanged';
  };

  const cellWithIconStyle = (x, y) => {
    return x === y || (x === null && selectedDate === 'X')
      ? 'subvalueData'
      : 'subvalueData valueCellChanged valueCellIcon';
  };

  return (
    <tr key={description} className="awardRow">
      <th scope="row" className="subvalueDescriptionAndTerm">
        <div className="subvalueDescriptionAndTermDiv">
          <div className="subvalueDescription">{description}</div>
          <div className="subvalueTerm">
            {mergedData(current, snapshot).map(item => (
              <div key={item.term} className="subvalueData subvalueTermData">
                {item.term}
              </div>
            ))}
          </div>
        </div>
      </th>
      {(snapshot && snapshot.length > 0 && selectedDate !== 'X') ||
      selectedDate === 'X' ? (
        <td className="subvalue">
          {mergedData(current, snapshot).map(item => (
            <div
              key={item.term}
              className={cellStyle(item.snapshotValue, item.currentValue)}
            >
              {item.snapshotValue}
            </div>
          ))}
        </td>
      ) : (
        <td className="subvalue">
          <div className="subvalueData">N/A</div>
        </td>
      )}
      {current.length > 0 ? (
        <td className="subvalue">
          {mergedData(current, snapshot).map(item => (
            <div
              key={item.term}
              className={cellWithIconStyle(
                item.snapshotValue,
                item.currentValue
              )}
            >
              <div>
                {selectedDate !== 'X' &&
                  item.snapshotValue !== item.currentValue && (
                    <OrangeChangedIcon className="hideSmallFormFactor icon" />
                  )}
                {item.currentValue}
              </div>
            </div>
          ))}
        </td>
      ) : (
        <td className="subvalue">
          <div className="subvalueData">N/A</div>
        </td>
      )}
    </tr>
  );
};

SubvaluesComparisonRow.displayName = 'SubvaluesComparisonRow';
SubvaluesComparisonRow.propTypes = {
  description: PropTypes.string.isRequired,
  current: PropTypes.array,
  snapshot: PropTypes.array,
};

export default SubvaluesComparisonRow;
