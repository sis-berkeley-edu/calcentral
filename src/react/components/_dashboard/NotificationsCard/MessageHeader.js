import React from 'react';
import PropTypes from 'prop-types';

import styles from './MessageHeader.module.scss';

const iconClasses = {
  alert: 'exclamation-circle',
  announcement: 'bullhorn',
  assignment: 'book',
  campusSolutions: 'sticky-note',
  discussion: 'comments',
  financial: 'usd',
  gradePosting: 'trophy',
  info: 'info-circle',
  message: 'check-circle',
  webcast: 'video-camera',
  webconference: 'video-camera',
};

const MessageIcon = ({ type }) => {
  const className = `fa fa-${iconClasses[type]} cc-left`;

  return (
    <div className={styles.icon}>
      <i className={className}></i>
    </div>
  );
};

MessageIcon.propTypes = {
  type: PropTypes.string,
};

const MessageHeader = ({ title, subtitle, type }) => {
  return (
    <div className={styles.messageHeader}>
      <MessageIcon type={type} />
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
  type: PropTypes.string,
};

export default MessageHeader;
