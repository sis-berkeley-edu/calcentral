import React, { Fragment } from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';

import PrimarySection from './PrimarySection';

const propTypes = {
  semester: PropTypes.object.isRequired,
  transferCredit: PropTypes.object.isRequired,
  isLawStudent: PropTypes.bool
};

const SemesterSections = ({ semester, transferCredit, isLawStudent }) => {
  const { totalUnits, totalLawUnits, isGradingComplete, classes, termId } = semester;

  const showUnitTotals = classes.map(klass => klass.academicCareer).find((career) => {
    return (career === 'GRAD' || career === 'LAW');
  });

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
    const primaries = klass.sections.flat().filter((section) => {
      return section.is_primary_section && !section.waitlisted;
    });

    return primaries.map(primary => {
      return {...primary, class: klass};
    });
  }).flat().filter(e => e !== undefined);

  const showPoints = classes.find(klass => {
    return klass.sections.find(section => section.grading.gradePointsAdjusted);
  }) ? true : false;

  return (
    <table className="cc-class-enrollments">
      <thead>
        <tr>
          <th>Class</th>
          <th>Title</th>
          <th className="cc-table-right cc-academic-summary-table-units">Un.</th>
          {totalLawUnits && <th className="cc-table-right cc-academic-summary-table-units">Law Un.</th>}
          <th>Gr.</th>
          <th>{!isLawStudent && showPoints && <Fragment>Pts.</Fragment>}</th>
        </tr>
      </thead>
      <tbody>
        {primarySections.map((section, index) => (
          <PrimarySection
            key={index}
            showPoints={showPoints}
            totalLawUnits={totalLawUnits}
            section={section}
            isLawStudent={isLawStudent}
          />
        ))}
      </tbody>

      {showUnitTotals &&
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

const mapStateToProps = ({ myStatus, myTransferCredit: transferCredit }) => {
  const {
    roles: {
      law: isLawStudent
    }
  } = myStatus;

  return { isLawStudent, transferCredit };
};

export default connect(mapStateToProps)(SemesterSections);
