import React from 'react';
import StyledNotice from 'react/components/StyledNotice';

export default function DegreeProgressNoticeContainer() {
  return (
    <StyledNotice background="gray" icon="info">
      Transfer course work for newly admitted students is currently under
      review. All eligible credit will be posted by the end of your first
      semester.
    </StyledNotice>
  );
}
