import { connect } from 'react-redux';
import { fetchWebMessages } from 'redux/actions/webMessagesActions';
import NotificationsCard from './NotificationsCard';

const groupBySource = (accumulator, message) => {
  if (accumulator.hasOwnProperty(message.source)) {
    accumulator[message.source].push(message);
  } else {
    accumulator[message.source] = [message];
  }

  return accumulator;
};

const mapStateToProps = ({
  myWebMessages: { archiveUrl, notifications = [], loaded },
}) => {
  return {
    archiveUrl,
    canSeeCSLinks: true,
    loaded,
    notifications: notifications.reduce(groupBySource, {}),
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

export default ConnectedNotificationsCard;
