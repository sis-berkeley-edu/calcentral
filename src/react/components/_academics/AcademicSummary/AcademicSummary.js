import React, { useEffect } from 'react';
import PropTypes from 'prop-types';
import { Provider, connect } from 'react-redux';
import { react2angular } from 'react2angular';

import store from 'Redux/store';
import { fetchAcademics } from 'Redux/actions/academicsActions';
import { fetchProfile } from 'Redux/actions/profileActions';
import { fetchTransferCredit } from 'Redux/actions/transferCreditActions';

import NotFound404 from '../../NotFound404';
import Spinner from '../../Spinner';
import Icon from '../../Icon/Icon';
import { ICON_PRINT } from '../../Icon/IconTypes';

import Enrollment from './Enrollment';
import StudentProfile from '../StudentProfile/StudentProfile';

import './AcademicSummary.scss';

const propTypes = {
  dispatch: PropTypes.func,
  featureEnabled: PropTypes.bool
};

const AcademicSummary = ({
  dispatch,
  featureEnabled,
  academicsLoaded,
  profileLoaded,
  statusLoaded,
  transferCreditLoaded
}) => {
  useEffect(() => {
    dispatch(fetchAcademics());
    dispatch(fetchProfile());
    dispatch(fetchTransferCredit());
  }, []);

  const printPage = () => {
    window.print();
  };

  if (featureEnabled) {
    const loaded = academicsLoaded && profileLoaded && statusLoaded && transferCreditLoaded;

    return (
      <div className="cc-page-academics">
        <div className="column">
          <h1 className="cc-heading-page-title cc-print-hide">
            <a href="/academics">My Academics</a> &raquo; Academic Summary
          </h1>
        </div>
        <div className="row">
          <div className="medium-10 medium-offset-1 column">
            <div className="cc-widget cc-academic-summary">
              <div className="cc-widget-title">
                <h2 className="cc-left">Academic Summary</h2>
                <button className="cc-button cc-button-blue cc-right cc-widget-title-button" onClick={printPage}>
                  <Icon name={ICON_PRINT} /> Print
                </button>
              </div>

              {loaded
                ? (
                  <div className="AcademicSummary__body">
                    <h3>Student Profile</h3>
                    <StudentProfile />
                    <Enrollment />
                  </div>
                )
                : <Spinner />
              }
            </div>
          </div>
        </div>
      </div>
    );
  } else {
    return <NotFound404 />;
  }
};

AcademicSummary.propTypes = propTypes;

const mapStateToProps = (state) => {
  const {
    myStatus: {
      hasAcademicsTab: featureEnabled,
      loaded: statusLoaded
    } = {},
    myAcademics: { loaded: academicsLoaded },
    myProfile: { loaded: profileLoaded },
    myTransferCredit: { loaded: transferCreditLoaded }
  } = state;

  const { myAcademics } = state;

  return {
    featureEnabled,
    academicsLoaded,
    profileLoaded,
    statusLoaded,
    transferCreditLoaded,
    myAcademics
  };
};

const ConnectedSummary = connect(mapStateToProps)(AcademicSummary);

const AcademicSummaryContainer = () => (
  <Provider store={store}>
    <ConnectedSummary />
  </Provider>
);


angular.module('calcentral.react').component('academicSummary', react2angular(AcademicSummaryContainer));

export default AcademicSummary;
