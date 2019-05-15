import React from 'react';
import PropTypes from 'prop-types';

const propTypes = {
  appointmentsInGraduatingTerm: PropTypes.bool,
  expectedGraduationTerm: PropTypes.object,
  isAdvisingStudentLookup: PropTypes.bool.isRequired
};

const GenericGraduation = ({ appointmentsInGraduatingTerm, expectedGraduationTerm }) => {
  if (expectedGraduationTerm) {
    return (
      <tr>
        <th>Terms Information</th>
        <td>
          <div className="cc-section-block">
            <div className="cc-text-light">Expected Graduation</div>
            <span>
              { appointmentsInGraduatingTerm &&
                <i className="fa fa-clock-o cc-icon-grey" style={{marginRight: '4px'}}></i>
              }
              <strong><span>{expectedGraduationTerm.termName}</span></strong>
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
