import React from 'react';
import PropTypes from 'prop-types';

import APILink from 'react/components/APILink';
import styles from './Messages.module.scss';

import 'icons/review.svg';

const Messages = ({ messages }) => {
  return (
    <div className={styles.messages}>
      {messages.map(({ source, title, actionText, link, fixedUrl }, index) => (
        <div key={index} className={styles.message}>
          <div className={styles.source}>{source}</div>
          <div className={styles.title}>{title}</div>

          {fixedUrl ? (
            <APILink
              {...fixedUrl}
              style={{ display: `flex`, marginTop: `10px` }}
            />
          ) : (
            <APILink {...link} style={{ display: `flex`, marginTop: `10px` }}>
              <img src="/assets/images/review.svg" width="15" />
              <span style={{ paddingLeft: `5px` }}>View and {actionText}</span>
            </APILink>
          )}
        </div>
      ))}
    </div>
  );
};

Messages.propTypes = {
  messages: PropTypes.arrayOf(
    PropTypes.shape({
      title: PropTypes.string,
      source: PropTypes.string,
    })
  ),
};

export default Messages;
