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
  totalUnitsPassedNotForGpa: PropTypes.number,
  totalPreviousCareerCumUnits: PropTypes.number,
  totalPreviousCareerLawUnits: PropTypes.number,
  transferUnitsAccepted: PropTypes.number
};

const CumulativeUnits = ({
  isCurrentSummerVisitor,
  totalUnits,
  totalLawUnits,
  totalTransferAndTestingUnits,
  totalUnitsTakenNotForGpa,
  totalUnitsPassedNotForGpa,
  totalPreviousCareerCumUnits,
  totalPreviousCareerLawUnits,
  transferUnitsAccepted
}) => {
  if (!isCurrentSummerVisitor && (totalUnits > 0 || totalLawUnits > 0)) {

    let summaryTotalLawUnits = totalLawUnits;
    let summaryTotalUnits = totalUnits;
    let summaryTotalTransferUnits = totalTransferAndTestingUnits;
    let showPNP = true;
    if (totalLawUnits > 0 || totalPreviousCareerLawUnits > 0) {
      summaryTotalLawUnits = totalLawUnits + totalPreviousCareerLawUnits;
      summaryTotalUnits = totalUnits + totalPreviousCareerCumUnits;
      summaryTotalTransferUnits = totalTransferAndTestingUnits + transferUnitsAccepted;
      showPNP = false;
    }

    return (
      <tr>
        <th>Cumulative Units</th>
        <td>
          <table className="student-profile__subtable">
            <tbody>
              <UnitsRow name="Total Units" value={summaryTotalUnits} />

              {unitsPresent(totalLawUnits) &&
                <UnitsRow name="Law Units" value={summaryTotalLawUnits} />
              }

              {unitsPresent(totalTransferAndTestingUnits) &&
                <UnitsRow name="Transfer Units" value={summaryTotalTransferUnits} />
              }

              {unitsPresent(totalUnitsTakenNotForGpa) && showPNP &&
                <UnitsRow name="P/NP Total" value={totalUnitsTakenNotForGpa} />
              }

              {unitsPresent(totalUnitsPassedNotForGpa) && showPNP &&
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
        summerVisitor: isCurrentSummerVisitor,
      } = {}
    } = {}
  } = myStatus;

  const {
    gpaUnits: {
      totalUnits,
      totalLawUnits,
      totalTransferAndTestingUnits,
      totalUnitsTakenNotForGpa,
      totalUnitsPassedNotForGpa,
      totalPreviousCareerCumUnits,
      totalPreviousCareerLawUnits,
      transferUnitsAccepted
    } = {}
  } = myAcademics;

  return {
    isCurrentSummerVisitor, 
    totalUnits,
    totalLawUnits,
    totalTransferAndTestingUnits,
    totalUnitsTakenNotForGpa,
    totalUnitsPassedNotForGpa,
    totalPreviousCareerCumUnits,
    totalPreviousCareerLawUnits,
    transferUnitsAccepted
  };
};

export default connect(mapStateToProps)(CumulativeUnits);
