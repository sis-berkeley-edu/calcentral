import React, { useState } from 'react';
import PropTypes from 'prop-types';

import { shortDateIfCurrentYear, parseDate } from 'functions/formatDate';

import Message from './Message';
import MessageHeader from './MessageHeader';
import MessageDetail from './MessageDetail';
import CompactNotification from './CompactNotification';

const SourcedMessages = ({
  source,
  date,
  messages,
  expandedItem,
  setExpandedItem,
  hasFocus,
  type,
}) => {
  const key = `${source}-${date}-${type}`;
  const isExpanded = expandedItem === key;
  const onClick = _event => {
    setExpandedItem(isExpanded ? '' : key);
  };

  const message = messages[0];
  const subtitle = `${message.source}, ${shortDateIfCurrentYear(
    parseDate(message.statusDate)
  )}`;

  if (messages.length === 1) {
    return (
      <Message onClick={onClick} isExpanded={isExpanded} hasFocus={hasFocus}>
        <MessageHeader
          title={message.title}
          subtitle={subtitle}
          type={message.type}
        />

        {isExpanded && <MessageDetail message={message} />}
      </Message>
    );
  }

  const [expandedMessage, setExpandedMessage] = useState('');

  const messageType = type === 'campusSolutions' ? 'notification' : type;
  const title = `${
    messages.length
  } ${messageType[0].toUpperCase()}${messageType.substring(1)}s`;

  return (
    <Message onClick={onClick} isExpanded={isExpanded} hasFocus={hasFocus}>
      <MessageHeader title={title} subtitle={subtitle} type={type} />

      {expandedItem === key && (
        <div style={{ marginTop: `15px` }}>
          {messages.map((message, index) => (
            <CompactNotification
              key={index}
              index={index}
              message={message}
              expandedMessage={expandedMessage}
              setExpandedMessage={setExpandedMessage}
              hasFocus={hasFocus}
            />
          ))}
        </div>
      )}
    </Message>
  );
};

SourcedMessages.propTypes = {
  messages: PropTypes.array,
  source: PropTypes.string,
  date: PropTypes.string,
  expandedItem: PropTypes.string,
  setExpandedItem: PropTypes.func,
  hasFocus: PropTypes.bool,
  type: PropTypes.string,
};

export default SourcedMessages;
