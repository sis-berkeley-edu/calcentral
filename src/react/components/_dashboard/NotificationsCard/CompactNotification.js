import React from 'react';
import PropTypes from 'prop-types';

import APILink from 'react/components/APILink';

import styles from './CompactNotification.module.scss';
import { parseDate, formatTime } from 'functions/formatDate';

const CompactNotification = ({ message, isExpanded, onClick }) => {
  const className = [
    styles.compactNotification,
    isExpanded ? styles.active : null,
  ].join(' ');

  return (
    <div className={className} onClick={e => onClick(e)}>
      <div>{message.title}</div>

      {isExpanded && (
        <div className={styles.detail}>
          <div className={styles.activityTime}>
            at {formatTime(parseDate(message.statusDateTime))}
          </div>
          <div
            className={styles.description}
            dangerouslySetInnerHTML={{ __html: message.description }}
          />
          <div className={styles.actionLink}>
            {message.sourceUrl}

            <strong>
              <APILink {...message.link} name={message.linkText} />
            </strong>
          </div>
        </div>
      )}
    </div>
  );
};

CompactNotification.propTypes = {
  message: PropTypes.object,
  isExpanded: PropTypes.bool,
  onClick: PropTypes.func,
};

CompactNotification.displayName = 'CompactNotification';

export default CompactNotification;
