import React from 'react';
import { connect } from 'react-redux';

const Careers = ({ careers, isCurrentSummerVisitor }) => {
  if (!isCurrentSummerVisitor && careers.length) {
    return (
      <tr>
        <th>{careers.length === 1 ? 'Academic Career' : 'Academic Careers'}</th>
        <td>{careers.map(career => <div key={career}>{career}</div>)}</td>
      </tr>
    );
  } else {
    return null;
  }
};

const mapStateToProps = ({ myAcademics, myStatus }) => {
  const {
    collegeAndLevel: {
      careers = []
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
    careers, isCurrentSummerVisitor
  };
};

export default connect(mapStateToProps)(Careers);
