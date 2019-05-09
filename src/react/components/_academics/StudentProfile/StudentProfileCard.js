import React, { useEffect } from 'react';
import PropTypes from 'prop-types';
import { Provider, connect } from 'react-redux';
import { react2angular } from 'react2angular';

import './StudentProfileCard.scss';

import store from 'Redux/store';
import { fetchAcademics } from 'Redux/actions/academicsActions';
import { fetchLawAwards } from 'Redux/actions/lawAwardsActions';
import { fetchProfile } from 'Redux/actions/profileActions';
import { fetchTransferCredit } from 'Redux/actions/transferCreditActions';

import CollegeAndLevelError from './CollegeAndLevelError';
import ConcurrentEnrollmentMessage from './ConcurrentEnrollmentMessage';
import StatusAsOf from './StatusAsOf';
import NameAndPhoto from './NameAndPhoto';
import Major from './Major';
import Minor from './Minor';
import Emphases from './Emphases';
import Careers from './Careers';
import Levels from './Levels';
import LawGraduation from './LawGraduation';
import UndergraduateGraduation from './UndergraduateGraduation';
import GraduateGraduation from './GraduateGraduation';
import GPAToggle from './GPAToggle';
import CumulativeUnits from './CumulativeUnits';

import Degrees from './Degrees';
import LawAwards from './LawAwards';

// const propTypes = {
//   names: PropTypes.array,
//   sid: PropTypes.string
// };

const propTypes = {
  dispatch: PropTypes.func.isRequired
};

const StudentProfileCard = ({ dispatch }) => {
  useEffect(() => {
    dispatch(fetchAcademics());
    dispatch(fetchProfile());
    dispatch(fetchTransferCredit());
    dispatch(fetchLawAwards());
  }, []);

  return (
    <section className="StudentProfileCard">
      <header>
        <h2>Profiles</h2>
      </header>
      <div className="StudentProfileCard--body">
        <CollegeAndLevelError />
        <ConcurrentEnrollmentMessage />
        <StatusAsOf />

        <table className="student-profile student-profile--mini">
          <tbody>
            <NameAndPhoto />
            <Major />
            <Minor />
            <Emphases />
            <Careers />
            <Levels />
            <UndergraduateGraduation isAdvisingStudentLookup={false} />
            <LawGraduation isAdvisingStudentLookup={false} />
            <GraduateGraduation isAdvisingStudentLookup={false} />
            <CumulativeUnits />
            <GPAToggle />
            <Degrees />
            <LawAwards showLink={true} />
          </tbody>
        </table>
      </div>
    </section>
  );
};

StudentProfileCard.propTypes = propTypes;

const mapStateToProps = ({ myProfile: { names }, myStatus: { sid } }) => {
  return { names, sid };
};

const ConnectedStudentProfileCard = connect(mapStateToProps)(StudentProfileCard);

const StudentProfileContainer = () => {
  return (
    <Provider store={store}>
      <ConnectedStudentProfileCard />
    </Provider>
  );
};

angular.module('calcentral.react').component('studentProfileCard', react2angular(StudentProfileContainer));
