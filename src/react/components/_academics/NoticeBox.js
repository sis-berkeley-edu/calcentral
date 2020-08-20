import React from 'react';
import PropTypes from 'prop-types';

import ReadMore from 'react/components/ReadMore';
import styles from './EnrollmentNotice.module.scss';
import 'icons/bullhorn-solid.svg';

const propTypes = {
  termId: PropTypes.string.isRequired,
  enrollmentTerms: PropTypes.array,
  enrollmentsLoaded: PropTypes.bool,
  messageKey: PropTypes.string,
};

export default function NoticeBox({
  termId,
  messageKey,
  enrollmentTerms,
  enrollmentsLoaded,
}) {
  const enrollmentTerm = enrollmentTerms.find(et => et.termId === termId);

  if (!enrollmentsLoaded) {
    return null;
  }

  const { descrlong: html } = enrollmentTerm ? enrollmentTerm[messageKey] : {};

  if (html) {
    return (
      <div className={styles.enrollmentNotice}>
        <div className={styles.messageContainer}>
          <ReadMore html={html} />
        </div>
      </div>
    );
  }

  return null;
}

NoticeBox.propTypes = propTypes;
