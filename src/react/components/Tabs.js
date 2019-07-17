import React from 'react';
import PropTypes from 'prop-types';

const Tab = ({ tab, current, setTab }) => {
  const className = tab === current ? 'Tab Tab--active' : 'Tab Tab--inactive';

  const onClick = (event, tab) => {
    event.stopPropagation();
    setTab(tab);
  };

  return (
    <li key={tab} onClick={(e) => onClick(e, tab)} className={className}>
      {tab}
    </li>
  );
};
Tab.propTypes = {
  tab: PropTypes.string,
  current: PropTypes.string,
  setTab: PropTypes.func
};

import './Tabs.scss';

const Tabs = ({ current, tabs, setTab }) => {
  return (
    <ul className="Tabs">
      {tabs.map(tab => (
        <Tab tab={tab} key={tab} setTab={setTab} current={current} />
      ))}
    </ul>
  );
};
Tabs.propTypes = {
  tabs: PropTypes.array,
  current: PropTypes.string,
  setTab: PropTypes.func
};

export default Tabs;
