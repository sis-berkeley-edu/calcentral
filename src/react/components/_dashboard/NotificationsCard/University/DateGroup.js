import React from 'react';
import PropTypes from 'prop-types';

import Messages from './Messages';
import DateLabel from '../DateLabel';

const DateGroup = ({ dateGroup: { date, messages } }) => {
  return (
    <div
      style={{
        borderBottom: `1px solid #eee`,
        display: `flex`,
      }}
    >
      <DateLabel date={date} />
      <Messages messages={messages} />
    </div>
  );
};

DateGroup.propTypes = {
  dateGroup: PropTypes.shape({
    date: PropTypes.instanceOf(Date),
    dateString: PropTypes.string,
    messages: PropTypes.arrayOf(
      PropTypes.shape({
        title: PropTypes.string,
      })
    ),
  }).isRequired,
};

export default DateGroup;
