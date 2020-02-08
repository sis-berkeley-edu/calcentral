import React from 'react';
import PropTypes from 'prop-types';

import ActionLink from './ActionLink';
import styles from './CompactNotification.module.scss';
import Linkify from 'react-linkify';

const CompactNotification = ({
  index,
  message,
  expandedMessage,
  setExpandedMessage,
  hasFocus,
}) => {
  const isExpanded = expandedMessage === index;

  const classNames = [
    styles.compactNotification,
    isExpanded ? styles.active : null,
    hasFocus ? null : styles.notFocused,
  ];

  const expand = e => {
    e.stopPropagation();
    setExpandedMessage(isExpanded ? '' : index);
  };

  return (
    <div className={classNames.join(' ')} onClick={expand}>
      <div>{message.title}</div>

      {isExpanded && (
        <div className={styles.detail}>
          <div className={styles.description}>
            <Linkify
              properties={{ target: '_blank', rel: 'noopener noreferrer' }}
            >
              {message.description}
            </Linkify>
          </div>

          <div className={styles.actionLink}>
            <ActionLink message={message} />
          </div>
        </div>
      )}
    </div>
  );
};

CompactNotification.propTypes = {
  index: PropTypes.number,
  message: PropTypes.object,
  expandedMessage: PropTypes.any,
  setExpandedMessage: PropTypes.func,
  hasFocus: PropTypes.bool,
};

CompactNotification.displayName = 'CompactNotification';

export default CompactNotification;
