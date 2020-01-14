import React from 'react';
import PropTypes from 'prop-types';
import { Provider, connect } from 'react-redux';
import { react2angular } from 'react2angular';

import store from 'Redux/store';

import { termFromId } from 'React/helpers/terms';
import RegistrationPeriod from './RegistrationPeriod';

import './RegistrationStatus.scss';

const byTermDescending = (a, b) => {
  return parseInt(b.termId) - parseInt(a.termId);
};

const statusForTerm = registration => {
  const { id: termId, year, semester } = termFromId(registration.term.id);

  const {
    showCnp: hasCNPWarning,
    cnpStatus,
    regStatus,
    positiveIndicators,
    termFlags,
  } = registration;

  return {
    termId,
    year,
    semester,
    hasCNPWarning,
    cnpStatus,
    regStatus,
    positiveIndicators,
    termFlags,
  };
};

const propTypes = {
  registrations: PropTypes.array,
  viewCompletedCalgrantLink: PropTypes.bool,
};

const SemesterStatuses = ({ registrations }) => {
  return (
    <div className="SemesterStatuses">
      {registrations.sort(byTermDescending).map((period, index) => (
        <RegistrationPeriod key={index} period={period} />
      ))}
    </div>
  );
};

SemesterStatuses.propTypes = propTypes;

const mapStateToProps = ({ myRegistrations = {}, myStatus = {} }) => {
  const { registrations } = myRegistrations;

  const { features: { regstatus: registrationStatusEnabled } = {} } = myStatus;

  const regArray = [];

  for (let termId in registrations) {
    if ({}.hasOwnProperty.call(registrations, termId)) {
      regArray.push(statusForTerm(registrations[termId]));
    }
  }

  return {
    registrations: regArray,
    registrationStatusEnabled,
  };
};

const ConnectedSemesterStatuses = connect(mapStateToProps)(SemesterStatuses);

const SemesterStatusesContainer = () => (
  <Provider store={store}>
    <ConnectedSemesterStatuses />
  </Provider>
);

angular
  .module('calcentral.react')
  .component('semesterStatuses', react2angular(SemesterStatusesContainer));
