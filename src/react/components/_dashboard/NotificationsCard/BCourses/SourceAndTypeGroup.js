import React from 'react';

import SingleNotification from './SingleNotification';
import MultiNotifications from './MultiNotifications';

const SourceAndTypeGroup = ({
  source,
  type,
  notifications,
  expanded,
  setExpanded,
}) => {
  if (notifications.length === 1) {
    return (
      <SingleNotification
        source={source}
        type={type}
        notification={notifications[0]}
        expanded={expanded}
        setExpanded={setExpanded}
      />
    );
  } else {
    return (
      <MultiNotifications
        source={source}
        type={type}
        notifications={notifications}
        expanded={expanded}
        setExpanded={setExpanded}
      />
    );
  }
};

export default SourceAndTypeGroup;
