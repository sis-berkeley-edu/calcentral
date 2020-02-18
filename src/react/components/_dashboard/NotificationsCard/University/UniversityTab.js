import React from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';

import { parseISO } from 'date-fns';

import APILink from 'react/components/APILink';
import DisclosureChevron from 'react/components/DisclosureChevron';

import NoNotfications from '../NoNotifications';
import DateGroup from './DateGroup';
import Unread from './Unread';

import { groupByDate } from '../notifications.module';
import types from 'react/types';

const UniversityNotifications = ({
  archiveUrl,
  displayAll,
  notifications,
  shownCount,
  showMore,
}) => {
  if (notifications.length === 0) {
    return (
      <NoNotfications type="University notifications">
        <APILink {...archiveUrl}>
          {archiveUrl.name} <i className="fa fa-arrow-right" />
        </APILink>
      </NoNotfications>
    );
  }

  const shownNotifications = displayAll
    ? notifications
    : notifications.slice(0, shownCount);

  const moreToShow = shownNotifications.length < notifications.length;
  const groupedByDate = shownNotifications.reduce(groupByDate, []);

  return (
    <>
      <Unread count={notifications.length} />

      <div style={{ marginTop: `10px` }}>
        {groupedByDate.map(dateGroup => {
          return <DateGroup key={dateGroup.date} dateGroup={dateGroup} />;
        })}
      </div>

      {moreToShow ? (
        <div style={{ padding: `15px 15px 0`, textAlign: `center` }}>
          <button className="cc-button-link" onClick={() => showMore()}>
            Show More <DisclosureChevron />
          </button>
        </div>
      ) : (
        <div style={{ padding: `15px 15px 0`, textAlign: `center` }}>
          <APILink {...archiveUrl}>
            View Past Notifications <i className="fa fa-arrow-right" />
          </APILink>
        </div>
      )}
    </>
  );
};

UniversityNotifications.displayName = 'UniversityNotifications';
UniversityNotifications.propTypes = {
  archiveUrl: types.apiLink,
  displayAll: PropTypes.bool,
  notifications: PropTypes.array,
  shownCount: PropTypes.number.isRequired,
  showMore: PropTypes.func.isRequired,
};

const mapStateToProps = ({
  myWebMessages: {
    universityNotifications: {
      archiveUrl,
      notifications = [],
      displayAll = false,
    },
  },
}) => {
  const datedNotifications = notifications
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
    archiveUrl,
    displayAll,
    notifications: datedNotifications,
  };
};

export default connect(mapStateToProps)(UniversityNotifications);
