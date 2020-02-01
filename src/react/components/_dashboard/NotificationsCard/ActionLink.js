import React from 'react';
import PropTypes from 'prop-types';

import APILink from 'react/components/APILink';

const ActionLink = ({ message }) => {
  if (message.emitter === 'bCourses') {
    return (
      <strong>
        <a href={message.url} onClick={e => e.stopPropagation()}>
          More info
        </a>
      </strong>
    );
  }

  return (
    <strong>
      <APILink {...message.link} name={message.linkText} />
    </strong>
  );
};

ActionLink.propTypes = {
  message: PropTypes.object,
};

export default ActionLink;
