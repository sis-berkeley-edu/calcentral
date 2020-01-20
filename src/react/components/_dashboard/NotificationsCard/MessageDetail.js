import React from 'react';
import PropTypes from 'prop-types';

import styles from './MessageDetail.module.scss';

import APILink from 'react/components/APILink';

const MessageDetail = ({ message }) => {
  return (
    <div className={styles.detail}>
      <div
        className={styles.html}
        dangerouslySetInnerHTML={{ __html: message.description }}
      />

      <strong>
        <APILink {...message.link} name={message.linkText} />
      </strong>
    </div>
  );
};

MessageDetail.propTypes = {
  message: PropTypes.object,
};

export default MessageDetail;
