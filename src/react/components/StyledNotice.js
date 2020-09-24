import React from 'react';
import PropTypes from 'prop-types';

import colors from 'react/colors';
import styles from './StyledNotice.module.scss';

import BullhornIcon from 'react/components/Icon/BullhornIcon';
import InfoIcon from 'react/components/Icon/InfoIcon';

export default function StyledNotice({ icon, background, children }) {
  return (
    <div className={`${styles.noticeWrapper} ${styles[background]}`}>
      <div className={styles.iconContainer}>
        {icon === 'bullhorn' && <BullhornIcon />}
        {icon === 'info' && <InfoIcon color={colors.dustyGray} />}
      </div>
      <div className={styles.messageContainer}>{children}</div>
    </div>
  );
}

StyledNotice.propTypes = {
  icon: PropTypes.oneOf(['bullhorn', 'info']).isRequired,
  background: PropTypes.oneOf(['gray', 'yellow']).isRequired,
  children: PropTypes.node,
};
