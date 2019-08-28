import React, { useEffect } from 'react';
import PropTypes from 'prop-types';
import { Provider, connect } from 'react-redux';
import { react2angular } from 'react2angular';

import store from 'Redux/store';

import { fetchStatusAndHolds } from 'Redux/actions/statusActions';
import { DisclosureItem, DisclosureItemTitle } from 'React/components/DisclosureItem';
import StatusDisclosure from './StatusDisclosure';
import RegistrationStatusIcon from '../RegistrationStatusIcon';

const StatusItem = ({
  status: {
    message, severity, detailedMessageHTML
  }
}) => {
  if (message === '') {
    return null;
  }

  return (
    <DisclosureItem>
      <DisclosureItemTitle>
        <RegistrationStatusIcon severity={severity} />
        {message}
      </DisclosureItemTitle>
      { detailedMessageHTML && (
        <StatusDisclosure>
          <div dangerouslySetInnerHTML={{__html: detailedMessageHTML}} />
        </StatusDisclosure>
      )}
    </DisclosureItem>
  );
};

StatusItem.propTypes = {
  status: PropTypes.object.isRequired
};

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
        <div className="TermRegistrationStatus" key={reg.termId} style={{ marginBottom: `15px` }}>
          <h4>{reg.termName}</h4>
          <StatusItem status={reg.status} />
          <StatusItem status={reg.cnpStatus} />
        </div>
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
