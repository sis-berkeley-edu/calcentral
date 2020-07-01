import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';
import { react2angular } from 'react2angular';

import ReduxProvider from 'react/components/ReduxProvider';

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
    return preview;
  }
}

const EnrollmentNotice = ({ termId, enrollmentTerms }) => {
  // if found in the message <read-more>, the component will show everything
  // before that message, and show a "Read more" button
  const cutDelimiter = '<read-more>';
  const [expanded, setExpanded] = useState(false);
  const [preview, more] = message.split(cutDelimiter);
  const enrollmentTerm = enrollmentTerms.find(et => et.termId === termId);

  if (enrollmentTerm.message === null) {
    return null;
  }

  const message = enrollmentTerm.message.descrlong;

  if (message === null || message === '') {
    return null;
  }

  return (
    <div className={styles.COVIDEnrollmentNotice}>
      <div className={styles.messageContainer}>
        {more ? (
          <>
            <div
              dangerouslySetInnerHTML={{
                __html: renderMessage(preview, more, expanded),
              }}
              aria-expanded={expanded}
            />
            <button
              className="cc-button-link"
              onClick={() => setExpanded(!expanded)}
            >
              {expanded ? 'Read less' : 'Read more'}
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

const ConnectedEnrollmentNotice = connect(mapStateToProps)(EnrollmentNotice);

const EnrollmentNoticeContainer = ({ termId }) => (
  <ReduxProvider>
    <ConnectedEnrollmentNotice termId={termId} />
  </ReduxProvider>
);

EnrollmentNoticeContainer.propTypes = {
  termId: PropTypes.string.isRequired,
};

angular
  .module('calcentral.react')
  .component('enrollmentNotice', react2angular(EnrollmentNoticeContainer));
