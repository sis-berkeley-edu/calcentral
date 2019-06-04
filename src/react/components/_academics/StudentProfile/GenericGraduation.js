import React, { Fragment } from 'react';
import PropTypes from 'prop-types';

const propTypes = {
  showCheckListLink: PropTypes.bool,
  appointmentsInGraduatingTerm: PropTypes.bool,
  showGraduationChecklist: PropTypes.bool,
  expectedGraduationTerm: PropTypes.object,
  isAdvisingStudentLookup: PropTypes.bool.isRequired,
  termsInAttendance: PropTypes.string
};

const GenericGraduation = ({
  showCheckListLink,
  appointmentsInGraduatingTerm,
  showGraduationChecklist,
  expectedGraduationTerm,
  isAdvisingStudentLookup,
  termsInAttendance
}) => {
  if (expectedGraduationTerm) {
    return (
      <tr>
        <th>Terms Information</th>
        <td>
          { termsInAttendance &&
            <div className="cc-section-block">
              <div className="cc-text-light">Terms in Attendance</div>
              <div>{ termsInAttendance }</div>
            </div>
          }
          <div className="cc-section-block">
            <div className="cc-text-light">Expected Graduation</div>
            <span>
              { appointmentsInGraduatingTerm &&
                <i className="fa fa-clock-o cc-icon-grey" style={{marginRight: '4px'}}></i>
              }
              <strong><span>{expectedGraduationTerm.termName}</span></strong>
            </span>
            { showCheckListLink && !isAdvisingStudentLookup &&
              <div className="cc-widget-profile-footnote">
                { showGraduationChecklist
                  ? (
                    <Fragment>
                      <a href="/academics/graduation_checklist">
                        <strong>View Graduation Checklist</strong>
                      </a>
                      <br />

                      <Fragment>
                        {expectedGraduationTerm.termName}
                        &nbsp;will be your final term to complete all degree requirements.
                        If you have questions, please contact your College Advisor.
                      </Fragment>
                    </Fragment>
                  )
                  : <Fragment>Consult your college advisor with questions or concerns.</Fragment>
                }
              </div>
            }
          </div>
        </td>
      </tr>
    );
  } else {
    return null;
  }
};

GenericGraduation.propTypes = propTypes;

export default GenericGraduation;
