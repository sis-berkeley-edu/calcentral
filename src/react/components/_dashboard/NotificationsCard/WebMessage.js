import React from 'react';
import PropTypes from 'prop-types';

import APILink from 'react/components/APILink';
import styles from './WebMessage.module.scss';

import { shortDateIfCurrentYear, parseDate } from 'functions/formatDate';

const WebMessage = ({ message, source, expandedItem, setExpandedItem }) => {
  const isExpanded = message.source == expandedItem;

  const onExpand = () => {
    if (source === expandedItem) {
      setExpandedItem('');
    } else {
      setExpandedItem(source);
    }
  };

  const classNames =
    expandedItem === source
      ? [styles.container, styles.active, styles.noFocus]
      : [styles.container, styles.inactive];

  return (
    <div className={classNames.join(' ')} onClick={() => onExpand()}>
      <div className={styles.header}>
        <div className={styles.icon}>
          <i className="fa fa-sticky-note cc-left"></i>
        </div>

        <div>
          <div className={styles.title}>{message.title}</div>
          <div>
            {message.source},{' '}
            {shortDateIfCurrentYear(parseDate(message.statusDate))}
          </div>
        </div>
      </div>

      {isExpanded && (
        <div className={styles.detail}>
          <div
            className={styles.html}
            dangerouslySetInnerHTML={{ __html: message.description }}
          />

          <APILink {...message.link} name={message.linkText} />
        </div>
      )}
    </div>
  );
};

WebMessage.propTypes = {
  source: PropTypes.string,
  selectedSource: PropTypes.string,
  setSelectedSource: PropTypes.func,
  message: PropTypes.object,
  cardHasFocus: PropTypes.bool,
  expandedItem: PropTypes.string,
  setExpandedItem: PropTypes.func,
};

WebMessage.displayName = 'WebMessage';

export default WebMessage;
