import React from 'react';
import PropTypes from 'prop-types';
import UnitsRow from './UnitsRow';

const unitsPresent = (units) => units !== null && units > 0;

const propTypes = {
  totalUnits: PropTypes.number,
  totalLawUnits: PropTypes.number,
  totalTransferAndTestingUnits: PropTypes.number,
  totalUnitsTakenNotForGpa: PropTypes.number,
  totalUnitsPassedNotForGpa: PropTypes.number
};

const CumulativeUnits = (props) => (
  <table className="student-profile__subtable">
    <tbody>
      <UnitsRow name="Total Units" value={props.totalUnits} />

      {unitsPresent(props.totalLawUnits) &&
        <UnitsRow name="Law Units" value={props.totalLawUnits} />
      }

      {unitsPresent(props.totalTransferAndTestingUnits) &&
        <UnitsRow name="Transfer Units" value={props.totalTransferAndTestingUnits} />
      }

      {unitsPresent(props.totalUnitsTakenNotForGpa) &&
        <UnitsRow name="P/NP Total" value={props.totalUnitsTakenNotForGpa} />
      }

      {unitsPresent(props.totalUnitsPassedNotForGpa) &&
        <UnitsRow name="P/NP Passed" value={props.totalUnitsPassedNotForGpa} />
      }
    </tbody>
  </table>
);

CumulativeUnits.propTypes = propTypes;

export default CumulativeUnits;
