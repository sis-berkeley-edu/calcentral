import React, { useEffect } from 'react';
import PropTypes from 'prop-types';
import { Provider, connect } from 'react-redux';
import { react2angular } from 'react2angular';

import store from 'Redux/store';

import { fetchStatusAndHolds } from 'Redux/actions/statusActions';

import TermRegistrationStatus from './TermRegistrationStatus';

const TermRegistrationStatuses = ({
  dispatch,
  termRegistrations
}) => {
  useEffect(() => {
    dispatch(fetchStatusAndHolds());
  });

  return (
    <div className="TermRegistrationStatuses" style={{ marginBottom: `15px` }}>
      {termRegistrations.map(reg => (
        <TermRegistrationStatus
          key={reg.termId}
          termRegistration={reg}
        />
      ))}
    </div>
  );
};

TermRegistrationStatuses.propTypes = {
  dispatch: PropTypes.func,
  termRegistrations: PropTypes.array
};

const mapStateToProps = ({ myStatusAndHolds }) => {
  const {
    termRegistrations = []
  } = myStatusAndHolds;

  return {
    termRegistrations
  };
};

const ConnectedTermRegistrationStatuses = connect(mapStateToProps)(TermRegistrationStatuses);

angular
.module('calcentral.react')
.component(
  'termRegistrationStatuses',
  react2angular(() => (
    <Provider store={store}>
      <ConnectedTermRegistrationStatuses />
    </Provider>
  ))
);
