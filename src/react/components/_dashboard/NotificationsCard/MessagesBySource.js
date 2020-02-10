import React, { useState } from 'react';
import PropTypes from 'prop-types';

import SourcedMessages from './SourcedMessages';

const sum = (acc, current) => {
  return acc + current;
};

const MessagesBySource = ({
  groupedNotifications,
  selectedSource,
  expandedItem,
  setExpandedItem,
  hasFocus,
}) => {
  const incrementBy = 10;
  const [showCount, setShowCount] = useState(incrementBy);
  const showMore = () => {
    setShowCount(showCount + incrementBy);
  };

  const totalCount = groupedNotifications
    .map(dateGroup => {
      return dateGroup.messagesBySource
        .map(source =>
          selectedSource === '' || source.sourceName === selectedSource ? 1 : 0
        )
        .reduce(sum, 0);
    })
    .reduce(sum, 0);

  const remaining = totalCount - showCount;

  let shown = 0;

  return (
    <>
      {groupedNotifications.map(dateGroup =>
        dateGroup.messagesBySource.map((source, index) => {
          if (
            (selectedSource === '' || source.sourceName === selectedSource) &&
            shown < showCount
          ) {
            shown += 1;

            return (
              <SourcedMessages
                key={index}
                date={dateGroup.date}
                source={source.sourceName}
                type={source.type}
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

      {remaining > 0 && (
        <button
          className="cc-button cc-widget-show-more"
          onClick={() => showMore()}
        >
          Show {remaining > incrementBy ? incrementBy : remaining} More
        </button>
      )}
    </>
  );
};

MessagesBySource.propTypes = {
  groupedNotifications: PropTypes.array,
  selectedSource: PropTypes.string,
  hasFocus: PropTypes.bool,
  expandedItem: PropTypes.string,
  setExpandedItem: PropTypes.func,
};

export default MessagesBySource;
