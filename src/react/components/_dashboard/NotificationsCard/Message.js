import React from 'react';
import PropTypes from 'prop-types';

import styles from './Message.module.scss';

const Message = ({ children, onClick, isExpanded, hasFocus }) => {
  const classNames = [
    styles.message,
    isExpanded ? styles.expanded : styles.collapsed,
    hasFocus ? styles.hasFocus : styles.notFocused,
  ];

  return (
    <div className={classNames.join(' ')} onClick={onClick}>
      {children}
    </div>
  );
};

Message.propTypes = {
  children: PropTypes.node,
  onClick: PropTypes.func,
  isExpanded: PropTypes.bool,
  hasFocus: PropTypes.bool,
};

export default Message;
