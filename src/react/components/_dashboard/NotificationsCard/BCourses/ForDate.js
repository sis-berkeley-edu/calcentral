import React from 'react';
import PropTypes from 'prop-types';

import SourceAndTypeGroup from './SourceAndTypeGroup';

const groupBySourceAndType = (acc, current) => {
  const group = acc.find(
    item => item.sourceName === current.sourceName && item.type === current.type
  );

  if (group) {
    group.notifications.push(current);
  } else {
    acc.push({
      sourceName: current.sourceName,
      type: current.type,
      notifications: [current],
    });
  }

  return acc;
};

const ForDate = ({ notifications, expanded, setExpanded }) => {
  const groups = notifications.reduce(groupBySourceAndType, []);

  return (
    <div style={{ flex: `1` }}>
      {groups.map((group, index) => (
        <SourceAndTypeGroup
          key={index}
          source={group.sourceName}
          type={group.type}
          notifications={group.notifications}
          expanded={expanded}
          setExpanded={setExpanded}
        />
      ))}
    </div>
  );
};

ForDate.displayName = 'BCoursesNotificationsForDate';
ForDate.propTypes = {
  notifications: PropTypes.array,
  expanded: PropTypes.bool,
  setExpanded: PropTypes.func,
};

export default ForDate;
