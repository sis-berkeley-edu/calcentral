import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';

import styles from './EnrollmentNotice.module.scss';
import 'icons/bullhorn-solid.svg';

const propTypes = {
  termId: PropTypes.string.isRequired,
  enrollmentTerms: PropTypes.array,
};

function renderMessage(preview, more, expanded) {
  if (expanded) {
    return [preview, more].join('');
  } else {
    return `${preview}...`;
  }
}

const EnrollmentNotice = ({ termId, enrollmentTerms }) => {
  // if found in the message <read-more>, the component will show everything
  // before that message, and show a "Read more" button
  const cutDelimiter = '<read-more>';
  const [expanded, setExpanded] = useState(false);
  const enrollmentTerm = enrollmentTerms.find(et => et.termId === termId);

  if (
    enrollmentTerm.message === null ||
    enrollmentTerm.message.descrlong === null ||
    enrollmentTerm.message.descrlong === ''
  ) {
    return null;
  }

  const message = enrollmentTerm.message.descrlong;
  const [preview, more] = message.split(cutDelimiter);

  return (
    <div className={styles.enrollmentNotice}>
      <div className={styles.messageContainer}>
        {more ? (
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
        ) : (
          <div dangerouslySetInnerHTML={{ __html: preview }} />
        )}
      </div>
    </div>
  );
};

EnrollmentNotice.propTypes = propTypes;

const mapStateToProps = ({ myEnrollments: { enrollmentTerms = [] } = {} }) => {
  return { enrollmentTerms };
};

export default connect(mapStateToProps)(EnrollmentNotice);
