import React, { Fragment } from 'react';
import PropTypes from 'prop-types';

const propTypes = {
  graduation: PropTypes.object.isRequired,
  termsInAttendance: PropTypes.string,
  isAdvisingStudentLookup: PropTypes.bool.isRequired
};

const GenericGraduation = (props) => {
  if (props.graduation.undergraduate.expectedGraduationTerm) {
    return (
      <tr>
        <th>Terms Information</th>
        <td>
          <div className="cc-section-block">
            <div className="cc-text-light">Expected Graduation</div>
            <span>
              { props.graduation.undergraduate.appointmentsInGraduatingTerm &&
                <i className="fa fa-clock-o cc-icon-grey" style={{marginRight: '4px'}}></i>
              }
              <strong><span>{props.graduation.undergraduate.expectedGraduationTerm.termName}</span></strong>
            </span>

            { !props.isAdvisingStudentLookup &&
              <div className="cc-widget-profile-footnote">
                { props.graduation.undergraduate.appointmentsInGraduatingTerm
                  ? (
                    <Fragment>
                      <a href="/academics/graduation_checklist">
                        <strong>View Graduation Checklist</strong>
                      </a>
                      <br />

                      <Fragment>
                        {props.graduation.undergraduate.expectedGraduationTerm.termName}
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
