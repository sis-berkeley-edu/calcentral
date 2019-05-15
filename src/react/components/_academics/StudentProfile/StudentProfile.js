import React from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';

import './StudentProfile.scss';

import Major from './Major';
import Minor from './Minor';

import Emphases from './Emphases';
import Careers from './Careers';
import Levels from './Levels';
import LawGraduation from './LawGraduation';
import UndergraduateGraduation from './UndergraduateGraduation';
import GraduateGraduation from './GraduateGraduation';
import CumulativeUnits from './CumulativeUnits';
import GPA from './GPA';
import Degrees from './Degrees';

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
      </tbody>
    </table>
  );
};

StudentProfile.propTypes = propTypes;

const mapStateToProps = ({ myProfile: { names }, myStatus: { sid } }) => {
  return { names, sid };
};

export default connect(mapStateToProps)(StudentProfile);
