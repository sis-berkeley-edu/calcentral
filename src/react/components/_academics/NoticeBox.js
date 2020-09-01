import React from 'react';
import PropTypes from 'prop-types';

import StyledNotice from 'react/components/StyledNotice';
import ReadMore from 'react/components/ReadMore';

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
      <StyledNotice background="yellow" icon="bullhorn">
        <ReadMore html={html} />
      </StyledNotice>
    );
  }

  return null;
}

NoticeBox.propTypes = propTypes;
