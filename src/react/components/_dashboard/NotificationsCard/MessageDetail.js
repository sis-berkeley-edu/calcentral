import React from 'react';
import PropTypes from 'prop-types';

import styles from './MessageDetail.module.scss';
import ActionLink from './ActionLink';
import Linkify from 'react-linkify';

const MessageDetail = ({ message }) => {
  return (
    <div className={styles.detail}>
      <div className={styles.html}>
        <Linkify properties={{ target: '_blank', rel: 'noopener noreferrer' }}>
          {message.description}
        </Linkify>
      </div>
      <ActionLink message={message} />
    </div>
  );
};

MessageDetail.propTypes = {
  message: PropTypes.object,
};

export default MessageDetail;
