import React from 'react';

import styles from './iconWrapper.module.scss';

function OverdueIcon() {
  return (
    <div className={styles.iconWrapper}>
      <div
        className="cc-icon fa fa-exclamation-circle cc-icon-red cc-icon-fa-size"
        style={{ display: 'block' }}
      />
    </div>
  );
}

export default OverdueIcon;
