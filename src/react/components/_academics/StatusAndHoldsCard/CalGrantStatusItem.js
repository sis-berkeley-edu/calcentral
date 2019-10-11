import React, { Fragment } from 'react';
import PropTypes from 'prop-types';

import StatusItem from './StatusItem';
import APILink from 'React/components/APILink';

const MessageWithLink = ({ message, link }) => (
  <Fragment>
    {message} <APILink {...link} name='Take action' />
  </Fragment>
);
MessageWithLink.propTypes = {
  message: PropTypes.string,
  link: PropTypes.object
};

const ExtendedMessageWithLink = ({ messageHTML, link}) => (
  <div>
    { messageHTML } <APILink {...link} />
  </div>
);
ExtendedMessageWithLink.propTypes = {
  messageHTML: PropTypes.string,
  link: PropTypes.object
}

const CalGrantStatusItem = ({ status }) => {
  if (!status.message) {
    return null;
  }

  if (status.severity === 'normal') {
    const completeStatus = {
      message: status.message,
      severity: status.severity,
      detailedMessageHTML: <APILink {...status.link} />
    };

    return (
      <StatusItem status={completeStatus} />
    );
  }

  const incompleteStatus = {
    message: <MessageWithLink message={status.message} link={status.link} />,
    severity: status.severity,
    detailedMessageHTML: <ExtendedMessageWithLink messageHTML={status.detailedMessageHTML} link={status.link} />
  };

  return (
    <StatusItem status={incompleteStatus} />
  );
};

CalGrantStatusItem.propTypes = {
  status: PropTypes.shape({
    severity: PropTypes.string,
    message: PropTypes.string,
    link: PropTypes.object,
    detailedMessageHTML: PropTypes.string
  })
};

export default CalGrantStatusItem;
