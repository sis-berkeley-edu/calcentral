import React from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';

const propTypes = {
  terms: PropTypes.array
};

const LawGraduation = ({ terms }) => {
  if (terms.length > 0) {
    return (
      <tr>
        <th>Expected Graduation</th>
        <td>
          {terms.map((term, index) => (
            <div key={index}>
              {term.plans.map(plan => (
                <div key={plan} className="cc-text-light">
                  <span key={plan}>{plan}</span>
                </div>
              ))}
              <div>
                {term.expectedGradTermNames.join(', ')}
              </div>
            </div>
          ))}
        </td>
      </tr>
    );
  } else {
    return null;
  }   
};

LawGraduation.propTypes = propTypes;

const mapStateToProps = ({ myAcademics }) => {
  const {
    graduation: {
      gradLaw: {
        expectedGraduationTerms:terms
      } = {}
    } = {}
  } = myAcademics;

  return {
    terms: terms || []
  };
};

export default connect(mapStateToProps)(LawGraduation);
