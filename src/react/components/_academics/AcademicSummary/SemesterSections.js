import React, { Fragment } from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';

import PrimarySection from './PrimarySection';

const propTypes = {
  semester: PropTypes.object.isRequired,
  transferCredit: PropTypes.object.isRequired,
  isLawStudent: PropTypes.bool,
  totalCurrentCumUnits: PropTypes.number,
  totalCurrentLawUnits: PropTypes.number,
  totalPreviousCareerCumUnits: PropTypes.number,
  totalPreviousCareerLawUnits: PropTypes.number
};

const SemesterSections = ({ semester, transferCredit, isLawStudent, totalCurrentLawUnits,
                            totalPreviousCareerLawUnits}) => {
  const { totalUnits, totalLawUnits, isGradingComplete, classes, termId } = semester;


  const lawTransferUnits = () => {
    if (transferCredit) {
      const sum = (accumulator, value) => (accumulator + value);

      if (transferCredit.law && transferCredit.law.detailed) {
        const units = transferCredit.law.detailed.map(transfer => {
          if (transfer.termId === termId) {
            return transfer.units;
          } else {
            return 0;
          }
        }).reduce(sum);

        const lawUnits = transferCredit.law.detailed.map(transfer => {
          if (transfer.termId === termId) {
            return transfer.lawUnits;
          } else {
            return 0;
          }
        }).reduce(sum);

        return { units, lawUnits };
      } else {
        return { units: 0, lawUnits: 0};
      }
    } else {
      return { units: 0, lawUnits: 0};
    }
  };

  const hasLawTransfer = lawTransferUnits().units > 0 || lawTransferUnits().lawUnits > 0;

  const primarySections = classes.map(klass => {
    const primary = klass.sections.flat().find((section) => {
      return section.is_primary_section && !section.waitlisted;
    });

    if (primary) {
      return {...primary, class: klass};
    }
  }).filter(e => e !== undefined);

  const hasLawUnits = (totalCurrentLawUnits > 0 || totalPreviousCareerLawUnits > 0)

  return (
    <table className="cc-class-enrollments">
      <thead>
        <tr>
          <th>Class</th>
          <th>Title</th>
          <th className="cc-table-right cc-academic-summary-table-units">Un.</th>
          {hasLawUnits && <th className="cc-table-right cc-academic-summary-table-units">Law Un.</th>}
          <th>Gr.</th>
          <th>{!hasLawUnits && <Fragment>Pts.</Fragment>}</th>
        </tr>
      </thead>
      <tbody>
        {primarySections.map((section, index) => (
          <PrimarySection
            key={index}
            showPoints={!hasLawUnits}
            section={section}
            isLawStudent={isLawStudent}
          />
        ))}
      </tbody>

      {hasLawUnits &&
        <tfoot>
          {hasLawTransfer &&
            <tr>
              <td colSpan="2" className="cc-table-right cc-academic-summary-table-units">
                Transfer Units:
              </td>
              <td className="cc-text-right cc-academic-summary-table-units">{lawTransferUnits().units.toFixed(1)}</td>
              <td className="cc-text-right cc-academic-summary-table-units">{lawTransferUnits().lawUnits.toFixed(1)}</td>
              <td>CR</td>
              <td className="cc-text-right"></td>
            </tr>
          }
          <tr>
            <td colSpan="2" className="cc-table-right cc-academic-summary-table-units">
              {isGradingComplete ? 'Earned Total:' : 'Enrolled Total:'}
            </td>
            <td className="cc-text-right cc-academic-summary-table-units"><strong>{totalUnits}</strong></td>

            {totalLawUnits &&
              <td className="cc-text-right cc-academic-summary-table-units"><strong>{totalLawUnits}</strong></td>
            }
            <td className="cc-text-right"></td>
            <td className="cc-text-right"></td>
          </tr>
        </tfoot>
      }
    </table>
  );
};

SemesterSections.propTypes = propTypes;

const mapStateToProps = ({ myStatus, myAcademics, myTransferCredit: transferCredit }) => {
  const {
    roles: {
      law: isLawStudent
    }
  }= myStatus;

  const {
    gpaUnits: {
      totalLawUnits: totalCurrentLawUnits,
      totalPreviousCareerLawUnits
    } = {}
  } = myAcademics;


  return { isLawStudent, totalCurrentLawUnits, totalPreviousCareerLawUnits, transferCredit };
};

export default connect(mapStateToProps)(SemesterSections);
