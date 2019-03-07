import React, { Component } from 'react';
import PropTypes from 'prop-types';

import './StudentProfile.scss';
import CumulativeUnits from './CumulativeUnits';
import ExpectedGraduation from './ExpectedGraduation';

import GPA from './GPA';
import Major from './Major';
import Minor from './Minor';
import Degrees from './Degrees';
import Level from './Level';

const propTypes = {
  academics: PropTypes.object.isRequired,
  studentProfile: PropTypes.object.isRequired,
  user: PropTypes.object.isRequired
};

class StudentProfile extends Component {
  constructor(props) {
    super(props);
    this.state = {
      emphases: props.academics.collegeAndLevel.designatedEmphases || [],
      degrees: props.academics.collegeAndLevel.degrees || [],
      academicRoles: props.user.academicRoles,
      careers: props.academics.collegeAndLevel.careers || [],
      gpa: props.academics.gpaUnits.gpa,
      gpaUnits: props.academics.gpaUnits,
      level: props.academics.collegeAndLevel.level,
      nonApLevel: props.academics.collegeAndLevel.nonApLevel,
      majors: props.academics.collegeAndLevel.majors || [],
      minors: props.academics.collegeAndLevel.minors || []
    };
  }

  preferredName() {
    if (this.props.studentProfile && this.props.studentProfile.names) {
      return this.props.studentProfile.names.find(item => item.type.code === 'PRI').formattedName;
    }
  }

  sid() {
    return this.props.user.sid;
  }

  showMajor() {
    return this.state.majors.length > 0;
  }

  showMinor() {
    return this.state.minors.length > 0;
  }

  showCareer() {
    return !this.hasCurrentRole('summerVisitor') && this.state.careers.length > 0;
  }

  showLevel() {
    return !this.hasCurrentRole('summerVisitor') && this.state.level;
  }

  showCumulativeUnits() {
    return !this.hasCurrentRole('summerVisitor') && this.hasUnits();
  }

  showDesignatedEmphases() {
    return true;
  }

  showGpa() {
    const nonLawGpaRole = this.state.gpa.find(item => item.role !== 'law');
    return !this.hasCurrentRole('summerVisitor') && nonLawGpaRole;
  }

  showDegreesConferred() {
    return this.state.degrees.length ? true : false;
  }

  notNonDegreeSeekingSummerVisitor() {
    return this.state.academicRoles.historical.summerVisitor && !this.state.academicRoles.historical.degreeSeeking;
  }

  hasCurrentRole(name) {
    return this.currentRoles()[name] === true;
  }

  currentRoles() {
    return this.state.academicRoles.current;
  }

  hasUnits() {
    return this.state.gpaUnits.totalUnits > 0 || this.state.gpaUnits.totalLawUnits > 0;
  }

  showGraduation() {
    return this.props.academics.graduation &&
      (this.props.academics.graduation.gradLaw || this.props.academics.graduation.undergraduate);
  }

  formatGPA(string) {
    return parseFloat(string).toFixed(3);
  }

  render() {
    return (
      <table className="student-profile">
        <tbody>
          <tr>
            <th>Name</th>
            <td>{this.preferredName()}</td>
          </tr>

          <tr>
            <th>Student ID</th>
            <td>{this.sid()}</td>
          </tr>

          {this.showMajor() && <Major majors={this.state.majors} />}
          {this.showMinor() && <Minor minors={this.state.minors} />}
          {this.showCareer() &&
            <tr>
              <th>{this.state.careers.length === 1 ? 'Academic Career' : 'Academic Careers'}</th>
              <td>{this.state.careers.map(career => <div key={career}>{career}</div>)}</td>
            </tr>
          }

          {this.showLevel() && <Level level={this.state.level} nonApLevel={this.state.nonApLevel} />}

          {this.showGraduation() &&
            <ExpectedGraduation
              graduation={this.props.academics.graduation}
              termsInAttendance={this.props.academics.collegeAndLevel.termsInAttendance}
              isAdvisingStudentLookup={false}
            />
          }

          {this.showCumulativeUnits() &&
            <tr>
              <th>Cumulative Units</th>
              <td>
                <CumulativeUnits {...this.state.gpaUnits} />
              </td>
            </tr>
          }

          {this.showGpa() && <GPA gpa={this.state.gpaUnits.gpa}/>}
          {this.showDegreesConferred() && <Degrees degrees={this.state.degrees} />}
        </tbody>
      </table>
    );
  }
}

StudentProfile.propTypes = propTypes;

export default StudentProfile;
