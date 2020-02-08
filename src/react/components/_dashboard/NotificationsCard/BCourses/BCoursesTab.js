import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';
import { parseISO } from 'date-fns';

import { groupByDate } from '../notifications.module';

import DisclosureChevron from 'react/components/DisclosureChevron';
import NoNotfications from '../NoNotifications';
import DateGroup from './DateGroup';

const BCoursesNotifications = ({ notifications, shownCount, showMore }) => {
  if (notifications.length === 0) {
    return <NoNotfications type="bCourses notifications" />;
  }

  const shownNotifications = notifications.slice(0, shownCount);
  const moreToShow = shownNotifications.length < notifications.length;
  const groupedByDate = shownNotifications.reduce(groupByDate, []);
  const [expanded, setExpanded] = useState('');

  return (
    <div>
      {groupedByDate.map(dateGroup => (
        <DateGroup
          key={dateGroup.date}
          dateGroup={dateGroup}
          expanded={expanded}
          setExpanded={setExpanded}
        />
      ))}

      {moreToShow && (
        <div style={{ padding: `15px 15px 0`, textAlign: `center` }}>
          <button className="cc-button-link" onClick={() => showMore()}>
            Show More <DisclosureChevron />
          </button>
        </div>
      )}
    </div>
  );
};

BCoursesNotifications.displayName = 'BCoursesNotifications';
BCoursesNotifications.propTypes = {
  notifications: PropTypes.arrayOf(
    PropTypes.shape({
      title: PropTypes.string,
    })
  ),
  shownCount: PropTypes.number,
  showMore: PropTypes.func,
};

const mapStateToProps = ({
  myWebMessages: { canvas_activities = [], webcasts = [] },
}) => {
  const datedNotifications = [...canvas_activities, ...webcasts]
    .map(notification => ({
      ...notification,
      statusDateString: notification.statusDate,
      statusDate: parseISO(notification.statusDate),
      statusDateTime: parseISO(notification.statusDateTime),
    }))
    .sort((a, b) => {
      if (a.statusDateString === b.statusDateString) {
        return a.statusDateTime > b.statusDateTime ? 1 : -1;
      } else {
        return a.statusDate < b.statusDate ? 1 : -1;
      }
    });

  return {
    notifications: datedNotifications,
  };
};

export default connect(mapStateToProps)(BCoursesNotifications);
