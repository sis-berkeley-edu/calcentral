import React from 'react';
import PropTypes from 'prop-types';

import styles from './MessageHeader.module.scss';

const MessageHeader = ({ title, subtitle }) => {
  return (
    <div className={styles.messageHeader}>
      <div className={styles.icon}>
        <i className="fa fa-sticky-note cc-left"></i>
      </div>
      <div>
        <div>
          <strong>{title}</strong>
        </div>
        <div>{subtitle}</div>
      </div>
    </div>
  );
};

MessageHeader.propTypes = {
  title: PropTypes.string,
  subtitle: PropTypes.string,
};

export default MessageHeader;
