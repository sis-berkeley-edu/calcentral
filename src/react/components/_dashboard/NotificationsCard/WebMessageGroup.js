import React, { useState } from 'react';
import PropTypes from 'prop-types';

import WebMessage from './WebMessage';
import CompactNotification from './CompactNotification';

import styles from './WebMessage.module.scss';
import { shortDateIfCurrentYear, parseDate } from 'functions/formatDate';

const WebMessageGroup = ({ messages, expandedItem, setExpandedItem }) => {
  const { source, statusDate } = messages[0];

  if (messages.length === 1) {
    return (
      <WebMessage
        source={source}
        message={messages[0]}
        expandedItem={expandedItem}
        setExpandedItem={setExpandedItem}
      />
    );
  }

  const [expanded, setExpanded] = useState(false);
  const [focusedNotification, setFocusedNotification] = useState(false);

  const containerClasses = [
    styles.container,
    expanded ? styles.active : styles.inactive,
  ].join(' ');

  const onClick = () => {
    setExpanded(!expanded);
  };

  return (
    <div className={containerClasses} onClick={() => onClick()}>
      <div className={styles.header}>
        <div className={styles.icon}>
          <i className="fa fa-sticky-note cc-left"></i>
        </div>

        <div>
          <div className={styles.title}>{messages.length} Notifications</div>
          <div>
            {source}, {shortDateIfCurrentYear(parseDate(statusDate))}
          </div>
        </div>
      </div>

      {expanded && (
        <div className={styles.notifications}>
          {messages.map((message, key) => {
            const isExpanded = focusedNotification === key;

            const onClick = e => {
              e.stopPropagation();

              if (isExpanded) {
                setFocusedNotification(false);
              } else {
                setFocusedNotification(key);
              }
            };

            return (
              <CompactNotification
                key={key}
                message={message}
                isExpanded={isExpanded}
                onClick={onClick}
              />
            );
          })}
        </div>
      )}
    </div>
  );
};

WebMessageGroup.propTypes = {
  source: PropTypes.string,
  // group: PropTypes.shape({
  //   source: PropTypes.string,
  //   messages: PropTypes.array,
  // }),
  messages: PropTypes.array,
  expandedItem: PropTypes.string,
  setExpandedItem: PropTypes.func,
};

WebMessageGroup.displayName = 'WebMessageGroup';

export default WebMessageGroup;
