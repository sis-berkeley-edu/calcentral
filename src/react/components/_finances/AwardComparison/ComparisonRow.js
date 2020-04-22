import React, { useContext } from 'react';
import PropTypes from 'prop-types';

import SelectedDateContext from './SelectedDateContext';
import OrangeChangedIcon from '../../Icon/OrangeChangedIcon';

import './AwardComparison.scss';

const ComparisonRow = ({ description, current, snapshot }) => {
  const { selectedDate: selectedDate } = useContext(SelectedDateContext);
  const sameValues =
    (snapshot === null && selectedDate === 'X') || current === snapshot
      ? true
      : false;
  let cellStyle = sameValues ? 'valueCell' : 'valueCell valueCellChanged';
  let cellWithIconStyle = sameValues
    ? 'valueCell'
    : 'valueCell valueCellChanged valueCellIcon';

  cellStyle =
    (snapshot && snapshot.indexOf('$') > -1) ||
    (current && current.indexOf('$') > -1)
      ? cellStyle + ' noWrap'
      : cellStyle;

  cellWithIconStyle =
    (snapshot && snapshot.indexOf('$') > -1) ||
    (current && current.indexOf('$') > -1)
      ? cellWithIconStyle + ' noWrap'
      : cellWithIconStyle;

  return (
    <tr key={description} className="awardRow">
      <th scope="row" className="valueDescription">
        {description}
      </th>
      <td className={cellStyle}>
        {snapshot || selectedDate === 'X' ? snapshot : 'N/A'}
      </td>
      <td className={cellWithIconStyle}>
        <div>
          {!sameValues && (
            <OrangeChangedIcon className="hideSmallFormFactor icon" />
          )}
          {current ? current : 'N/A'}
        </div>
      </td>
    </tr>
  );
};

ComparisonRow.displayName = 'AwardComparisonComparisonRow';
ComparisonRow.propTypes = {
  description: PropTypes.string.isRequired,
  current: PropTypes.string,
  snapshot: PropTypes.string,
};

export default ComparisonRow;
