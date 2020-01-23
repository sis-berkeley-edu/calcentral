import React from 'react';
import PropTypes from 'prop-types';

import APILink from 'react/components/APILink';

import styles from './CompactNotification.module.scss';

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
  index: PropTypes.number,
  message: PropTypes.object,
  expandedMessage: PropTypes.any,
  setExpandedMessage: PropTypes.func,
  hasFocus: PropTypes.bool,
};

CompactNotification.displayName = 'CompactNotification';

export default CompactNotification;
