import React from 'react';
import PropTypes from 'prop-types';

import SourcedMessages from './SourcedMessages';

const MessagesBySource = ({
  groupedNotifications,
  selectedSource,
  expandedItem,
  setExpandedItem,
  hasFocus,
}) => (
  <>
    {groupedNotifications.map(dateGroup =>
      dateGroup.messagesBySource.map((source, index) => {
        if (selectedSource === '' || source.sourceName === selectedSource) {
          return (
            <SourcedMessages
              key={index}
              date={dateGroup.date}
              source={source.sourceName}
              messages={source.messages}
              expandedItem={expandedItem}
              setExpandedItem={setExpandedItem}
              hasFocus={hasFocus}
            />
          );
        } else {
          return null;
        }
      })
    )}
  </>
);

MessagesBySource.propTypes = {
  groupedNotifications: PropTypes.array,
  selectedSource: PropTypes.string,
  hasFocus: PropTypes.bool,
  expandedItem: PropTypes.string,
  setExpandedItem: PropTypes.func,
};

export default MessagesBySource;
