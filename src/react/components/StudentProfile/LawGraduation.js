import React from 'react';
import PropTypes from 'prop-types';

const propTypes = {
  terms: PropTypes.array
};

const LawGraduation = (props) => {
  if (props.terms.length > 0) {
    return (
      <tr>
        <th>Expected Graduation</th>
        <td>
          {props.terms.map((term, index) => (
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

export default LawGraduation;
