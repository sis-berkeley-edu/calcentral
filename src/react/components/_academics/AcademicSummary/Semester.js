import React, { Component, Fragment } from 'react';
import PropTypes from 'prop-types';
import PrimarySection from './PrimarySection';

import './Semester.scss';

const propTypes = {
  canViewGrades: PropTypes.bool.isRequired,
  transferCredit: PropTypes.object
};

class Semester extends Component {
  showPoints() {
    const result = this.props.classes.find(klass => {
      return klass.sections.find(section => section.grading.gradePointsAdjusted);
    });

    return result ? true : false;
  }

  enrolled() {
    return this.props.hasEnrollmentData;
  }

  withdrawn() {
    return this.props.hasWithdrawalData;
  }

  enrolledAndNotWithdrawn() {
    return this.enrolled() && !this.withdrawn();
  }

  notEnrolledHasStudy() {
    return !this.enrolled() && this.props.hasStudyProgData;
  }

  primarySections() {
    return this.props.classes.map(klass => {
      const primary = klass.sections.flat().find((section) => {
        return section.is_primary_section && !section.waitlisted;
      });

      return {...primary, class: klass};
    });
  }

  showUnitTotals() {
    return this.props.classes.map(klass => klass.academicCareer).find((career) => {
      return (career === 'GRAD' || career === 'LAW');
    });
  }

  lawTransferUnits() {
    if (this.props.transferCredit) {
      const sum = (accumulator, value) => (accumulator + value);

      if (this.props.transferCredit.law && this.props.transferCredit.law.detailed) {
        const units = this.props.transferCredit.law.detailed.map(transfer => {
          if (transfer.termId === this.props.termId) {
            return transfer.units;
          } else {
            return 0;
          }
        }).reduce(sum);

        const lawUnits = this.props.transferCredit.law.detailed.map(transfer => {
          if (transfer.termId === this.props.termId) {
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
  }

  hasLawTransfer() {
    if (this.lawTransferUnits().units > 0 || this.lawTransferUnits().lawUnits > 0) {
      return true;
    }
  }

  render() {
    return (
      <div className="Semester">
        <div className="Semester__header" style={{ overflow: 'hidden' }}>
          {this.enrolledAndNotWithdrawn() &&
            <h4>
              <a className="cc-left" href={`/academics/semester/${this.props.slug}`}>
                {this.props.name}
              </a>
            </h4>
          }

          {(this.withdrawn() || !this.enrolled() || this.notEnrolledHasStudy()) &&
            <h4 className="cc-left">{this.props.name}</h4>
          }

          {this.withdrawn() &&
            <div className="cc-left cc-academics-semester-status">
              {this.props.withdrawalStatus.withcnclTypeDescr}
              {this.props.withdrawalStatus.withcnclFromDate}
            </div>
          }

          {this.props.hasStudyProgData &&
            <span className="cc-left cc-academics-semester-status">
              {this.props.studyProg.studyprogTypeDescr}
            </span>
          }
        </div>

        <div className="Semester__honors">
        </div>

        <div className="Semester__body cc-table">
          {this.props.hasEnrolledClasses && !this.withdrawn() &&
            <table className="cc-class-enrollments">
              <thead>
                <tr>
                  <th>Class</th>
                  <th>Title</th>
                  <th className="cc-table-right cc-academic-summary-table-units">Un.</th>

                  {this.props.totalLawUnits &&
                    <th className="cc-table-right cc-academic-summary-table-units">Law Un.</th>
                  }

                  <th>Gr.</th>
                  <th>
                    {this.showPoints() && <Fragment>Pts.</Fragment>}
                  </th>
                </tr>
              </thead>

              <tbody>
                {this.primarySections().map((section, index) => (
                  <PrimarySection
                    key={index}
                    showPoints={this.showPoints()}
                    canViewGrades={this.props.canViewGrades}
                    totalLawUnits={this.props.totalLawUnits}
                    {...section}
                  />
                ))}
              </tbody>

              {this.showUnitTotals() &&
                <tfoot>
                  {this.hasLawTransfer() &&
                    <tr>
                      <td colSpan="2" className="cc-table-right cc-academic-summary-table-units">
                        Transfer Units:
                      </td>
                      <td className="cc-text-right cc-academic-summary-table-units">{this.lawTransferUnits().units.toFixed(1)}</td>
                      <td className="cc-text-right cc-academic-summary-table-units">{this.lawTransferUnits().lawUnits.toFixed(1)}</td>
                      <td>CR</td>
                      <td className="cc-text-right"></td>
                    </tr>
                  }
                  <tr>
                    <td colSpan="2" className="cc-table-right cc-academic-summary-table-units">
                      {this.props.isGradingComplete ? 'Earned Total:' : 'Enrolled Total:'}
                    </td>
                    <td className="cc-text-right cc-academic-summary-table-units"><strong>{this.props.totalUnits}</strong></td>

                    {this.props.totalLawUnits &&
                      <td className="cc-text-right cc-academic-summary-table-units"><strong>{this.props.totalLawUnits}</strong></td>
                    }
                    <td className="cc-text-right"></td>
                    <td className="cc-text-right"></td>
                  </tr>
                </tfoot>
              }
            </table>
          }
        </div>
      </div>
    );
  }
}

Semester.propTypes = propTypes;

export default Semester;
