import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';
import { enableOAuth } from 'functions/user';
import { react2angular } from 'react2angular';

import './NoBconnected.scss';

const NoBconnected = ({
  mode,
  actingAsUid,
  delegateActingAsUid,
  advisorActingAsUid,
  applicationLayer,
}) => {
  const [showReminder, setShowReminder] = useState(false);

  const toggleShowReminder = function() {
    setShowReminder(!showReminder);
  };

  const actingAsAnotherUser =
    actingAsUid || advisorActingAsUid || delegateActingAsUid;

  const className = 'NoBconnected';

  return (
    <div className={className}>
      {mode === 'upnext' && (
        <div>
          <span>Want to see events from your bCal calendar?&nbsp;</span>
          {!actingAsAnotherUser && (
            <button
              className="cc-button-link"
              onClick={() => enableOAuth('Google', applicationLayer)}
            >
              Connect
            </button>
          )}
          {actingAsAnotherUser && <span>Connect</span>} CalCentral to your
          bConnected Google calendar account, then Accept.
          {!showReminder && (
            <span>
              {' '}
              <button
                className="cc-button-link"
                onClick={() => toggleShowReminder()}
              >
                Show more
              </button>
            </span>
          )}
        </div>
      )}
      {mode === 'main' && (
        <div>
          <p>
            Connect CalCentral to your campus bConnected <em>email</em>,{' '}
            <em>calendar</em> and <em>drive</em> account.
          </p>
          <p>
            Click Connect to go to a Google page, then Accept to complete the
            setup with CalCentral.{' '}
            {!showReminder && (
              <button
                className="cc-button-link"
                onClick={() => setShowReminder(!showReminder)}
              >
                Show more
              </button>
            )}
          </p>
        </div>
      )}
      {showReminder && (
        <div className="NoBconnected__revealed-text">
          <p>
            Why connect? From your Dashboard, you will be able to see when you
            have new bMail email messages and bCal calendar events, as well as
            your tasks and today&apos;s events.
          </p>
          <p>
            Not ready? You can connect later on the{' '}
            <a href="/profile/bconnected">bConnected page</a>.
          </p>
        </div>
      )}
    </div>
  );
};

const mapStateToProps = ({ myStatus, config }) => {
  const {
    actingAsUid = false,
    advisorActingAsUid = false,
    delegateActingAsUid = false,
  } = myStatus;

  const { applicationLayer = 'development' } = config;

  return {
    actingAsUid,
    advisorActingAsUid,
    delegateActingAsUid,
    applicationLayer,
  };
};

NoBconnected.propTypes = {
  actingAsUid: PropTypes.oneOfType([PropTypes.string, PropTypes.bool]),
  advisorActingAsUid: PropTypes.oneOfType([PropTypes.string, PropTypes.bool]),
  delegateActingAsUid: PropTypes.oneOfType([PropTypes.string, PropTypes.bool]),
  mode: PropTypes.string,
  applicationLayer: PropTypes.string,
};

angular
  .module('calcentral.react')
  .component('noBconnected', react2angular(NoBconnected));

export default connect(mapStateToProps)(NoBconnected);
