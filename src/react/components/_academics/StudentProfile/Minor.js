import React from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';

const propTypes = {
  minors: PropTypes.array
};

const Minor = ({ minors }) => {
  if (minors.length) {
    return (
      <tr>
        <th>{minors.length === 1 ? 'Minor' : 'Minors'}</th>
        <td>
          {minors.map((minorObj, index) => (
            <div key={index}>
              <div className="cc-text-light">{minorObj.college}</div>
              <div>{minorObj.minor}</div>
              {minorObj.subPlans.map((subPlan, index) => (
                <div key={index} className="cc-widget-profile-indent">{subPlan}</div>
              ))}
            </div>
          ))}
        </td>
      </tr>
    );
  } else {
    return null;
  }
};

Minor.propTypes = propTypes;

const mapStateToProps = ({ myAcademics }) => {
  const {
    collegeAndLevel: {
      minors = []
    } = {}
  } = myAcademics;

  return {
    minors
  };
};

export default connect(mapStateToProps)(Minor);
