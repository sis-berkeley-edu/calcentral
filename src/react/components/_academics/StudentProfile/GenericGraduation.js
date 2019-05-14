import React from 'react';
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
