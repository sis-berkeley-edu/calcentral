import React, { useEffect, useState } from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';
import { react2angular } from 'react2angular';

import Card from 'react/components/Card';
import Spinner from 'react/components/Spinner';
import ReduxProvider from 'react/components/ReduxProvider';
import { fetchWebMessages } from 'redux/actions/webMessagesActions';

import { TabSwitcher, Tab } from './Tabs';
import BCoursesTab from './BCourses/BCoursesTab';
import UniversityTab from './University/UniversityTab';

import useShowMore from './useShowMore';

const NotificationsCard = ({
  fetchNotifications,
  loaded,
  notificationsCount,
}) => {
  useEffect(() => {
    fetchNotifications();
  }, []);
  const tabs = ['University', 'bCourses'];
  const [UNIVERSITY_TAB, BCOURSES_TAB] = tabs;
  const [isLoaded, setIsLoaded] = useState(loaded);
  const [shownNotificationsCount, showMoreNotifications] = useShowMore(5);
  const [shownCoursesCount, showMoreCourses] = useShowMore(10);
  const [currentTab, setCurrentTab] = useState(UNIVERSITY_TAB);

  // Use local state to determine when the data loads, which allows checking
  // the notifications count and change the default tab if the university
  // notifications count is zero
  if (!isLoaded && loaded) {
    if (notificationsCount === 0) {
      setCurrentTab(BCOURSES_TAB);
    }

    setIsLoaded(true);
  }

  return (
    <Card title="Notifications">
      {isLoaded ? (
        <>
          <TabSwitcher>
            {tabs.map(tab => (
              <Tab
                tab={tab}
                key={tab}
                current={currentTab}
                setCurrent={setCurrentTab}
              />
            ))}
          </TabSwitcher>

          {currentTab === 'University' && (
            <UniversityTab
              shownCount={shownNotificationsCount}
              showMore={showMoreNotifications}
            />
          )}

          {currentTab === 'bCourses' && (
            <BCoursesTab
              shownCount={shownCoursesCount}
              showMore={showMoreCourses}
            />
          )}
        </>
      ) : (
        <Spinner />
      )}
    </Card>
  );
};

NotificationsCard.displayName = 'NotificationsCard';
NotificationsCard.propTypes = {
  notificationsCount: PropTypes.number,
  canSeeCSLinks: PropTypes.bool,
  fetchNotifications: PropTypes.func.isRequired,
  loaded: PropTypes.bool,
};

const mapStateToProps = ({
  myWebMessages: {
    loaded,
    universityNotifications: { notifications = [] } = {},
  },
}) => {
  return {
    loaded,
    notificationsCount: notifications.length,
  };
};

const mapDispatchToProps = dispatch => {
  return {
    fetchNotifications: () => {
      dispatch(fetchWebMessages());
    },
  };
};

const ConnectedNotificationsCard = connect(
  mapStateToProps,
  mapDispatchToProps
)(NotificationsCard);

const NotificationsCardContainer = () => (
  <ReduxProvider>
    <ConnectedNotificationsCard />
  </ReduxProvider>
);

export default NotificationsCardContainer;

angular
  .module('calcentral.react')
  .component('notificationsCard', react2angular(NotificationsCardContainer));
