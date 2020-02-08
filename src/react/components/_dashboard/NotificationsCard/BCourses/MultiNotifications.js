import React from 'react';
import PropTypes from 'prop-types';
import DisclosureChevron from 'react/components/DisclosureChevron';

import Linkify from 'react-linkify';
import styles from './SourceAndTypeGroup.module.scss';

import GradedLabel from './GradedLabel';
import CountBadge from './CountBadge';

import Notification from './notification';

const MiniNotification = ({ notification, expanded, setExpanded }) => {
  const isExpanded = notification.id === expanded;

  const expand = () => {
    isExpanded ? setExpanded('') : setExpanded(notification.id);
  };

  return (
    <div>
      <div
        className={styles.miniNotificationHeader}
        onClick={() => expand()}
        style={{ display: `flex` }}
      >
        <div style={{ width: `20px` }}>
          <DisclosureChevron expanded={isExpanded} />
        </div>
        <div style={{ flex: `1` }}>
          {notification.type === 'gradeposting' && <GradedLabel />}{' '}
          {notification.title}
        </div>
      </div>

      {isExpanded && (
        <div
          style={{
            marginLeft: `20px`,
            paddingTop: `5px`,
          }}
        >
          <Linkify>{notification.description}</Linkify>

          <p style={{ paddingTop: `15px`, marginBottom: `5px` }}>
            <a
              href={notification.url}
              onClick={e => e.stopPropagation()}
              target="_blank"
              rel="noopener noreferrer"
            >
              {Notification.linkText(notification)}
            </a>
          </p>
        </div>
      )}
    </div>
  );
};

MiniNotification.displayName = 'MiniNotification';
MiniNotification.propTypes = {
  notification: PropTypes.shape({
    id: PropTypes.string,
    title: PropTypes.string,
    source: PropTypes.string,
    type: PropTypes.string,
    url: PropTypes.string,
    description: PropTypes.string,
  }),
  expanded: PropTypes.bool,
  setExpanded: PropTypes.func,
};

const MultiNotifications = ({
  source,
  type,
  notifications,
  expanded,
  setExpanded,
}) => {
  const count = notifications.length;
  return (
    <div className={styles.multiNotificationGroup}>
      <div className={styles.header}>
        <div className={styles.sourceLabel}>{source}</div>
        <div className={styles.secondaryLabel}>
          {Notification.labelForType(type)} <CountBadge count={count} />
        </div>
      </div>

      <div className={styles.miniNotifications}>
        {notifications.map((notification, index) => (
          <MiniNotification
            key={index}
            notification={notification}
            expanded={expanded}
            setExpanded={setExpanded}
          />
        ))}
      </div>
    </div>
  );
};

MultiNotifications.displayName = 'MultiNotifications';
MultiNotifications.propTypes = {
  source: PropTypes.string,
  type: PropTypes.string,
  notifications: PropTypes.array,
  expanded: PropTypes.bool,
  setExpanded: PropTypes.func,
};

export default MultiNotifications;
