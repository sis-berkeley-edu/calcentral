import React from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';

import '../StudentProfile/StudentProfile.scss';
import Major from '../StudentProfile/Major';
import Minor from '../StudentProfile/Minor';
import Emphases from '../StudentProfile/Emphases';
import Careers from '../StudentProfile/Careers';
import Levels from '../StudentProfile/Levels';
import LawGraduation from '../StudentProfile/LawGraduation';
import UndergraduateGraduation from '../StudentProfile/UndergraduateGraduation';
import GraduateGraduation from '../StudentProfile/GraduateGraduation';
import CumulativeUnits from '../StudentProfile/CumulativeUnits';
import GPA from '../StudentProfile/GPA';
import Degrees from '../StudentProfile/Degrees';
import LawAwards from '../StudentProfile/LawAwards';

const propTypes = {
  names: PropTypes.array,
  sid: PropTypes.string
};

const StudentProfile = (props) => {
  const { names, sid } = props;
  const preferredName = names.find(item => item.type.code === 'PRI').formattedName;

  return (
    <table className="student-profile">
      <tbody>
        <tr>
          <th>Name</th>
          <td>{preferredName}</td>
        </tr>
        <tr>
          <th>Student ID</th>
          <td>{sid}</td>
        </tr>

        <Major />
        <Minor />
        <Emphases />
        <Careers />
        <Levels />
        <UndergraduateGraduation isAdvisingStudentLookup={false} showCheckListLink={true} />
        <GraduateGraduation isAdvisingStudentLookup={false} showCheckListLink={true} />
        <LawGraduation isAdvisingStudentLookup={false} />
        <CumulativeUnits />
        <GPA />
        <Degrees />
        <LawAwards />
      </tbody>
    </table>
  );
};

StudentProfile.propTypes = propTypes;

const mapStateToProps = ({ myProfile: { names }, myStatus: { sid } }) => {
  return { names, sid };
};

export default connect(mapStateToProps)(StudentProfile);
