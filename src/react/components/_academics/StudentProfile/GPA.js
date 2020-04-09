import React from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';

const propTypes = {
  gpa: PropTypes.array,
  currentlySummerVisitor: PropTypes.bool,
  myStatus: PropTypes.object
};

const formatGpaCumulative = (gpa) => {
  if (gpa.role === 'law') {
    return 'N/A';
  } else {
    return parseFloat(gpa.cumulativeGpa).toFixed(3);
  }
};

const GPA = ({ gpa, currentlySummerVisitor, myStatus}) => {
  const nonLawGpaRole = gpa.find(item => item.role !== 'law');
  const isLawStudent = myStatus.roles.law;
  const isJointLawStudent = myStatus.academicRoles.current.lawJointDegree;

  if (gpa.length && !currentlySummerVisitor && nonLawGpaRole && !isLawStudent && !isJointLawStudent) {
    return (
      <tr>
        <th>Cumulative GPA</th>
        <td>
          {gpa.length === 1
            ? formatGpaCumulative(gpa[0])
            : (
              <table className="student-profile__subtable">
                <tbody>
                  {gpa.map(theGpa => (
                    <tr key={theGpa.roleDescr}>
                      <th>{theGpa.roleDescr}</th>
                      <td>{formatGpaCumulative(theGpa)}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            )
          }
        </td>
      </tr>
    );
  } else {
    return null;
  }
};

GPA.propTypes = propTypes;

const mapStateToProps = ({ myAcademics, myStatus }) => {
  const {
    gpaUnits: {
      gpa = []
    } = {}
  } = myAcademics;

  const {
    academicRoles: {
      current: {
        summerVisitor: currentlySummerVisitor
      }
    }
  } = myStatus;

  return { gpa, currentlySummerVisitor, myStatus };
};

export default connect(mapStateToProps)(GPA);
