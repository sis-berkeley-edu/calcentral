import React, { useEffect, useState } from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';
import { react2angular } from 'react2angular';

import Card from 'react/components/Card';
import Spinner from 'react/components/Spinner';
import ReduxProvider from 'react/components/ReduxProvider';
import useFocus from 'react/useFocus';
import { fetchWebMessages } from 'redux/actions/webMessagesActions';

import ArchiveLink from './ArchiveLink';
import SourceFilter from './SourceFilter';
import SourcedMessages from './SourcedMessages';

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
          {groupedNotifications.map(dateGroup =>
            dateGroup.messagesBySource.map((source, index) => {
              if (
                selectedSource === '' ||
                source.sourceName === selectedSource
              ) {
                return (
                  <SourcedMessages
                    key={index}
                    date={dateGroup.date}
                    source={source.sourceName}
                    messages={source.messages}
                    expandedItem={expandedItem}
                    setExpandedItem={setExpandedItem}
                    hasFocus={hasFocus}
                  />
                );
              } else {
                return null;
              }
            })
          )}

          {canSeeCSLinks && <ArchiveLink url={archiveUrl} />}
        </>
      ) : (
        <Spinner />
      )}
    </Card>
  );
};

NotificationsCard.displayName = 'NotificationsCard';
NotificationsCard.propTypes = {
  archiveUrl: PropTypes.string,
  canSeeCSLinks: PropTypes.bool,
  fetchNotifications: PropTypes.func.isRequired,
  groupedNotifications: PropTypes.array.isRequired,
  loaded: PropTypes.bool,
  sources: PropTypes.array.isRequired,
};

const groupByDate = (accumulator, message) => {
  const group = accumulator.find(group => group.date === message.statusDate);

  if (group) {
    group.messages.unshift(message);
  } else {
    accumulator.push({ date: message.statusDate, messages: [message] });
  }

  return accumulator;
};

const groupBySource = (accumulator, message) => {
  const group = accumulator.find(group => group.sourceName === message.source);

  if (group) {
    group.messages.push(message);
  } else {
    accumulator.push({ sourceName: message.source, messages: [message] });
  }

  return accumulator;
};

const mapStateToProps = ({
  myStatus: { canSeeCSLinks },
  myWebMessages: { archiveUrl, notifications = [], loaded },
}) => {
  const sources = [
    ...new Set(notifications.map(notification => notification.source)),
  ].sort();

  const groupedNotifications = notifications
    .sort((a, b) => {
      return a.statusDateTime < b.statusDateTime ? 1 : -1;
    })
    .reduce(groupByDate, [])
    .map(group => {
      return {
        date: group.date,
        messagesBySource: group.messages.reduce(groupBySource, []),
      };
    });

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
