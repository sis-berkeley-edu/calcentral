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
          {minors.map((minors, index) => (
            <div key={index}>
              <div className="cc-text-light">{minors.college}</div>
              <div>{minors.minor}</div>
              {minors.minor.subPlan && <div className="cc-widget-profile-indent">{minors.minor.subPlan}</div>}
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
