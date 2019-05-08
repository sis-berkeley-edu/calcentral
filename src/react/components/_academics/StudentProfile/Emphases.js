import React from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';

const propTypes = {
  emphases: PropTypes.array
};

const Emphases = ({ emphases }) => {
  if (emphases.length) {
    return (
      <tr>
        <th>
          { emphases.length === 1
            ? 'Designated Emphasis'
            : 'Designated Emphases'
          }
        </th>
        <td>
          {emphases.map((emphasis, index) => (
            <div key={index}>
              <div className="cc-text-light">{emphasis.college}</div>
              <div>{emphasis.designatedEmphasis}</div>
              {emphasis.subPlan &&
                <div className="cc-widget-profile-indent">{emphasis.subPlan}</div>
              }
            </div>
          ))}
        </td>
      </tr>
    );
  } else {
    return null;
  }
};

const mapStateToProps = ({ myAcademics = {} }) => {
  const {
    collegeAndLevel: {
      designatedEmphases: emphases = []
    } = {}
  } = myAcademics;

  return { emphases };
};

Emphases.propTypes = propTypes;

export default connect(mapStateToProps)(Emphases);
