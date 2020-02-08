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

const NotificationsCard = ({ fetchNotifications, loaded }) => {
  const [shownNotificationsCount, showMoreNotifications] = useShowMore(5);
  const [shownCoursesCount, showMoreCourses] = useShowMore(5);

  const tabs = ['University', 'bCourses'];
  const [currentTab, setCurrentTab] = useState(tabs[0]);

  useEffect(() => {
    fetchNotifications();
  }, []);

  return (
    <Card title="Notifications">
      {loaded ? (
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
  canSeeCSLinks: PropTypes.bool,
  fetchNotifications: PropTypes.func.isRequired,
  loaded: PropTypes.bool,
};

const mapStateToProps = ({ myWebMessages: { loaded } }) => {
  return {
    loaded,
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
