import React, { useEffect, useState } from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';
import { react2angular } from 'react2angular';

import APILink from 'react/components/APILink';
import Card from 'react/components/Card';
import Spinner from 'react/components/Spinner';
import ReduxProvider from 'react/components/ReduxProvider';
import useFocus from 'react/useFocus';
import { fetchWebMessages } from 'redux/actions/webMessagesActions';

import SourceFilter from './SourceFilter';
import MessagesBySource from './MessagesBySource';

const NotificationsCard = ({
  archiveUrl,
  canSeeCSLinks,
  fetchNotifications,
  groupedNotifications,
  loaded,
  sources,
}) => {
  const [expandedItem, setExpandedItem] = useState('');
  const [selectedSource, setSelectedSource] = useState('');

  // useFocus is used to track whether the user is interacting with the card or
  // has clicked somewhere else on the page
  const [node, hasFocus] = useFocus();

  useEffect(() => {
    fetchNotifications();
  }, []);

  return (
    <Card
      node={node}
      title="Notifications"
      secondaryContent={
        <SourceFilter sources={sources} setSelectedSource={setSelectedSource} />
      }
    >
      {loaded ? (
        <>
          <MessagesBySource
            groupedNotifications={groupedNotifications}
            selectedSource={selectedSource}
            expandedItem={expandedItem}
            setExpandedItem={setExpandedItem}
            hasFocus={hasFocus}
          />

          {canSeeCSLinks && (
            <div
              className="cc-text-center cc-widget-padding"
              style={{ marginBottom: `-15px` }}
            >
              <APILink {...archiveUrl} />
            </div>
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
  archiveUrl: PropTypes.object,
  canSeeCSLinks: PropTypes.bool,
  fetchNotifications: PropTypes.func.isRequired,
  groupedNotifications: PropTypes.array.isRequired,
  loaded: PropTypes.bool,
  sources: PropTypes.array.isRequired,
};

import {
  groupByDate,
  byStatusDateTimeAsc,
  dateSourcedMessages,
} from './notifications.module';

const mapStateToProps = ({
  myStatus: { canSeeCSLinks },
  myWebMessages: { archiveUrl, notifications = [], loaded },
}) => {
  const sources = [
    ...new Set(notifications.map(notification => notification.source)),
  ].sort();

  const groupedNotifications = notifications
    .sort(byStatusDateTimeAsc)
    .reduce(groupByDate, [])
    .map(dateSourcedMessages);

  return {
    archiveUrl,
    canSeeCSLinks,
    loaded,
    sources,
    groupedNotifications,
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
