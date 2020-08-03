import React, { useState } from 'react';
import PropTypes from 'prop-types';

function renderMessage(preview, more, expanded) {
  if (expanded) {
    return [preview, more].join('');
  } else {
    return `${preview}...`;
  }
}

export default function ReadMore({ html }) {
  // if found in the message <read-more>, the component will show everything
  // before that message, and show a "Read more" button
  const cutDelimiter = '<read-more>';
  const [expanded, setExpanded] = useState(false);

  if (html === null || html === '') {
    return null;
  }

  const [preview, more] = html.split(cutDelimiter);

  if (more) {
    return (
      <>
        <div
          dangerouslySetInnerHTML={{
            __html: renderMessage([preview], more, expanded),
          }}
          aria-expanded={expanded}
        />
        <button
          className="cc-button-link"
          onClick={() => setExpanded(!expanded)}
        >
          {expanded ? 'Show less' : 'Show more'}
        </button>
      </>
    );
  }

  return <div dangerouslySetInnerHTML={{ __html: preview }} />;
}

ReadMore.propTypes = {
  html: PropTypes.string,
};
