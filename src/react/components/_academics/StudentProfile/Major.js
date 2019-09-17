import React from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';

const propTypes = {
  majors: PropTypes.array
};

const Major = ({ majors }) => {
  if (majors.length) {
    return (
      <tr>
        <th>{majors.length === 1 ? 'Major' : 'Majors'}</th>
        <td>
          {majors.map((major, index) => (
            <div key={index}>
              <div className="cc-text-light">{major.college}</div>
              <div>{major.major}</div>
              {major.subPlans.map((subPlan, index) => (
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

Major.propTypes = propTypes;

const mapStateToProps = ({ myAcademics }) => {
  const {
    collegeAndLevel: {
      majors = []
    } = {}
  } = myAcademics;

  return {
    majors
  };
};

export default connect(mapStateToProps)(Major);
