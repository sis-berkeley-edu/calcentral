import React from 'react';
import PropTypes from 'prop-types';

import styles from './Tabs.module.scss';

export const TabSwitcher = ({ children }) => (
  <div className={styles.switcher}>{children}</div>
);

TabSwitcher.propTypes = {
  children: PropTypes.node,
};

export const Tab = ({ current, setCurrent, tab }) => {
  const currentClasses = [styles.tab, styles.currentTab].join(' ');
  const inactiveClasses = [styles.tab, styles.inactiveTab].join(' ');

  if (tab === current) {
    return <div className={currentClasses}>{tab}</div>;
  }

  return (
    <div className={inactiveClasses} onClick={() => setCurrent(tab)}>
      {tab}
    </div>
  );
};

Tab.propTypes = {
  current: PropTypes.string,
  tab: PropTypes.string,
  setCurrent: PropTypes.func,
};
