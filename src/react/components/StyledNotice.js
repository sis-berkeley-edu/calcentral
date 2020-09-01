import React from 'react';
import PropTypes from 'prop-types';

import styles from './StyledNotice.module.scss';

import 'icons/bullhorn-solid.svg';
import 'icons/exclamation-circle-solid.svg';

export default function StyledNotice({ icon, background, children }) {
  return (
    <div className={`${styles.noticeWrapper} ${styles[background]}`}>
      <div className={`${styles.messageContainer} ${styles[icon]}`}>
        {children}
      </div>
    </div>
  );
}

StyledNotice.propTypes = {
  icon: PropTypes.oneOf(['bullhorn', 'info']).isRequired,
  background: PropTypes.oneOf(['gray', 'yellow']).isRequired,
  children: PropTypes.node,
};
