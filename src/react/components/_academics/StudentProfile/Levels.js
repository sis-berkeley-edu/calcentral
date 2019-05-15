import React from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';

const propTypes = {
  levels: PropTypes.array,
  isCurrentSummerVisitor: PropTypes.bool
};

const Levels = ({levels, isCurrentSummerVisitor}) => {
  if (!isCurrentSummerVisitor && levels.length) {
    return (
      <tr>
        <th>Level</th>
        <td>
          {levels.map((level, index) => (
            <div key={index}>
              <span>{level}</span>
            </div>
          ))}
        </td>
      </tr>
    );
  } else {
    return null;
  }
};

Levels.propTypes = propTypes;

const mapStateToProps = ({ myAcademics = {}, myStatus = {} }) => {
  const {
    collegeAndLevel: {
      levels
    } = {}
  } = myAcademics;

  const {
    academicRoles: {
      current: {
        summerVisitor: isCurrentSummerVisitor
      } = {}
    } = {}
  } = myStatus;

  return {
    levels: (levels || []),
    isCurrentSummerVisitor
  };
};

export default connect(mapStateToProps)(Levels);
