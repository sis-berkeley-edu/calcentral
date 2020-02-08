import React from 'react';
import PropTypes from 'prop-types';

import 'icons/circle-checkmark.svg';

const NoNotifications = ({ children, type }) => {
  return (
    <div style={{ textAlign: `center`, marginTop: `40px` }}>
      <div style={{ textAlign: `center` }}>
        <img src="/assets/images/circle-checkmark.svg" width="80" height="80" />
      </div>
      <p style={{ marginTop: `30px` }}>
        You are up to date!
        <br />
        No new {type} to show.
      </p>

      {children}
    </div>
  );
};

NoNotifications.displayName = 'NoNotifications';
NoNotifications.propTypes = {
  children: PropTypes.node,
  type: PropTypes.string.isRequired,
};

export default NoNotifications;
