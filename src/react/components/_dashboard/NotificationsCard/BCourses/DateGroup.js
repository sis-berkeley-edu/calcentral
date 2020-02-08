import React from 'react';
import PropTypes from 'prop-types';
import ForDate from './ForDate';
import DateLabel from '../DateLabel';

const DateGroup = ({
  dateGroup: { date, messages },
  expanded,
  setExpanded,
}) => {
  return (
    <div
      style={{
        borderBottom: `1px solid #eee`,
        display: `flex`,
      }}
    >
      <DateLabel date={date} />
      <ForDate
        notifications={messages}
        expanded={expanded}
        setExpanded={setExpanded}
      />
    </div>
  );
};

DateGroup.propTypes = {
  dateGroup: PropTypes.shape({
    date: PropTypes.string,
    messages: PropTypes.array,
  }),
  expanded: PropTypes.bool,
  setExpanded: PropTypes.func,
};

export default DateGroup;
