import React, { useEffect, useState } from 'react';
import PropTypes from 'prop-types';
import { react2angular } from 'react2angular';
import { connect } from 'react-redux';
import { fetchWebMessages } from 'redux/actions/webMessagesActions';

import useFocus from 'react/useFocus';
import ReduxProvider from 'components/ReduxProvider';
import NoMessages from '../_dashboard/NotificationsCard/NoMessages';
import WidgetSubtitle from 'react/components/WidgetSubtitle';
import MessagesBySource from '../_dashboard/NotificationsCard/MessagesBySource';

import {
  groupByDate,
  byStatusDateTimeAsc,
  dateAndTypeSourcedMessages,
  filterByAidYear,
} from 'react/components/_dashboard/NotificationsCard/notifications.module';

const FinancialAidMessages = ({
  fetchNotifications,
  notifications,
  loaded,
  year,
}) => {
  useEffect(() => {
    fetchNotifications();
  }, []);

  const [expandedItem, setExpandedItem] = useState('');

  // useFocus is used to track whether the user is interacting with the card or
  // has clicked somewhere else on the page
  const [node, hasFocus] = useFocus();

  const aidYearNotifications = notifications
    .filter(filterByAidYear(year))
    .sort(byStatusDateTimeAsc)
    .reduce(groupByDate, [])
    .map(dateAndTypeSourcedMessages);

  if (loaded) {
    return (
      <div ref={node}>
        <WidgetSubtitle>Messages</WidgetSubtitle>

        {aidYearNotifications.length > 0 ? (
          <div style={{ padding: `0 15px` }}>
            <MessagesBySource
              groupedNotifications={aidYearNotifications}
              selectedSource={''}
              setSelectedSource={() => {}}
              expandedItem={expandedItem}
              setExpandedItem={setExpandedItem}
              hasFocus={hasFocus}
            />
          </div>
        ) : (
          <NoMessages year={year} />
        )}
      </div>
    );
  }

  return null;
};

FinancialAidMessages.propTypes = {
  fetchNotifications: PropTypes.func,
  loaded: PropTypes.bool,
  notifications: PropTypes.array,
  year: PropTypes.string,
};

const mapStateToProps = ({
  myWebMessages: {
    universityNotifications: { archiveUrl, notifications = [] } = {},
    loaded,
  },
}) => {
  return {
    archiveUrl,
    notifications,
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

const ConnectedFinancialAidMessages = connect(
  mapStateToProps,
  mapDispatchToProps
)(FinancialAidMessages);

const FinancialAidMessagesContainer = ({ year }) => (
  <ReduxProvider>
    <ConnectedFinancialAidMessages year={year} />
  </ReduxProvider>
);

FinancialAidMessagesContainer.propTypes = {
  year: PropTypes.string,
};

angular
  .module('calcentral.react')
  .component(
    'financialAidMessages',
    react2angular(FinancialAidMessagesContainer)
  );
