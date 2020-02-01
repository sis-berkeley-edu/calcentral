import React from 'react';
import PropTypes from 'prop-types';

import styles from './MessageDetail.module.scss';
import ActionLink from './ActionLink';

const MessageDetail = ({ message }) => {
  return (
    <div className={styles.detail}>
      <div
        className={styles.html}
        dangerouslySetInnerHTML={{ __html: message.description }}
      />
      <ActionLink message={message} />
    </div>
  );
};

MessageDetail.propTypes = {
  message: PropTypes.object,
};

export default MessageDetail;
