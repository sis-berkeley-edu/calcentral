import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';
import { react2angular } from 'react2angular';

import ReduxProvider from 'react/components/ReduxProvider';

import styles from './COVIDEnrollmentNotice.module.scss';
import 'icons/bullhorn-solid.svg';

const propTypes = {
  termId: PropTypes.string.isRequired,
  enrollmentTerms: PropTypes.array,
};

const COVIDEnrollmentNotice = ({ termId, enrollmentTerms }) => {
  const threshold = 140;
  const [expanded, setExpanded] = useState(false);
  const enrollmentTerm = enrollmentTerms.find(et => et.termId === termId);

  if (enrollmentTerm.message === null) {
    return null;
  }

  const message =
    enrollmentTerm.message.descrlong || enrollmentTerm.message.messageText;

  if (message === null || message === '') {
    return null;
  }

  const shownMessage = expanded ? message : message.substring(0, threshold);

  return (
    <div className={styles.COVIDEnrollmentNotice}>
      <div className={styles.messageContainer}>
        {message.length > threshold ? (
          <>
            <div dangerouslySetInnerHTML={{ __html: shownMessage }} />
            <button
              className="cc-button-link"
              onClick={() => setExpanded(!expanded)}
            >
              {expanded ? 'Read less' : 'Read more'}
            </button>
          </>
        ) : (
          <div dangerouslySetInnerHTML={{ __html: message }} />
        )}
      </div>
    </div>
  );
};

COVIDEnrollmentNotice.propTypes = propTypes;

const mapStateToProps = ({ myEnrollments: { enrollmentTerms = [] } = {} }) => {
  return { enrollmentTerms };
};

const ConnectedCOVIDEnrollmentNotice = connect(mapStateToProps)(
  COVIDEnrollmentNotice
);

const COVIDEnrollmentNoticeContainer = ({ termId }) => (
  <ReduxProvider>
    <ConnectedCOVIDEnrollmentNotice termId={termId} />
  </ReduxProvider>
);

COVIDEnrollmentNoticeContainer.propTypes = {
  termId: PropTypes.string.isRequired,
};

angular
  .module('calcentral.react')
  .component(
    'covidEnrollmentNotice',
    react2angular(COVIDEnrollmentNoticeContainer)
  );
