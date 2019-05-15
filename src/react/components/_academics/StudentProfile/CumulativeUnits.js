import React from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';

import UnitsRow from './UnitsRow';

const unitsPresent = (units) => units !== null && units > 0;

const propTypes = {
  isCurrentSummerVisitor: PropTypes.bool,
  totalUnits: PropTypes.number,
  totalLawUnits: PropTypes.number,
  totalTransferAndTestingUnits: PropTypes.number,
  totalUnitsTakenNotForGpa: PropTypes.number,
  totalUnitsPassedNotForGpa: PropTypes.number
};

const CumulativeUnits = ({
  isCurrentSummerVisitor,
  totalUnits,
  totalLawUnits,
  totalTransferAndTestingUnits,
  totalUnitsTakenNotForGpa,
  totalUnitsPassedNotForGpa
}) => {
  if (!isCurrentSummerVisitor && (totalUnits > 0 || totalLawUnits > 0)) {
    return (
      <tr>
        <th>Cumulative Units</th>
        <td>
          <table className="student-profile__subtable">
            <tbody>
              <UnitsRow name="Total Units" value={totalUnits} />

              {unitsPresent(totalLawUnits) &&
                <UnitsRow name="Law Units" value={totalLawUnits} />
              }

              {unitsPresent(totalTransferAndTestingUnits) &&
                <UnitsRow name="Transfer Units" value={totalTransferAndTestingUnits} />
              }

              {unitsPresent(totalUnitsTakenNotForGpa) &&
                <UnitsRow name="P/NP Total" value={totalUnitsTakenNotForGpa} />
              }

              {unitsPresent(totalUnitsPassedNotForGpa) &&
                <UnitsRow name="P/NP Passed" value={totalUnitsPassedNotForGpa} />
              }
            </tbody>
          </table>
        </td>
      </tr>
    );
  } else {
    return null;
  }
};

CumulativeUnits.propTypes = propTypes;

const mapStateToProps = ({ myAcademics, myStatus }) => {
  const {
    academicRoles: {
      current: {
        summerVisitor: isCurrentSummerVisitor
      } = {}
    } = {}
  } = myStatus;

  const {
    gpaUnits: {
      totalUnits,
      totalLawUnits,
      totalTransferAndTestingUnits,
      totalUnitsTakenNotForGpa,
      totalUnitsPassedNotForGpa
    } = {}
  } = myAcademics;

  return {
    isCurrentSummerVisitor, 
    totalUnits,
    totalLawUnits,
    totalTransferAndTestingUnits,
    totalUnitsTakenNotForGpa,
    totalUnitsPassedNotForGpa
  };
};

export default connect(mapStateToProps)(CumulativeUnits);
