import React, { useEffect, Fragment } from 'react';
import PropTypes from 'prop-types';
import { react2angular } from 'react2angular';
import { Provider, connect } from 'react-redux';

import store from 'Redux/store';
import { fetchStatusAndHolds } from 'Redux/actions/statusActions';

import RegistrationStatusItemsForTerm from './RegistrationStatusItemsForTerm';

const RegistrationStatusItems = ({ dispatch, termRegistrations }) => {
  useEffect(() => {
    dispatch(fetchStatusAndHolds());
  }, []);

  return (
    <Fragment>
      {termRegistrations.map(reg => (
        <RegistrationStatusItemsForTerm key={reg.termId} termRegistration={reg} />
      ))}
    </Fragment>
  );
};

RegistrationStatusItems.propTypes = {
  dispatch: PropTypes.func.isRequired,
  termRegistrations: PropTypes.array.isRequired
};

const mapStateToProps = ({ myStatusAndHolds }) => {
  const {
    termRegistrations = []
  } = myStatusAndHolds;

  return {
    termRegistrations
  };
};

const ConnectedRegistrationStatusItems = connect(mapStateToProps)(RegistrationStatusItems);

angular.module('calcentral.react').component(
  'registrationStatusItems',
  react2angular(() => (
    <Provider store={store}>
      <ConnectedRegistrationStatusItems />
    </Provider>
  ))
);
