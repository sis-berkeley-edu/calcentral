import React from 'react';
import PropTypes from 'prop-types';

import StatusItem from './StatusItem';
import CalGrantStatusItem from './CalGrantStatusItem';

const TermRegistrationStatus = ({ termRegistration: {
  termName,
  termId,
  isShown,
  registrationStatus,
  cnpStatus,
  calgrantStatus
} }) => {
  if (isShown) {
    return (
      <div className="TermRegistrationStatus" key={termId} style={{ marginBottom: `15px` }}>
        <h4>{termName}</h4>
        { registrationStatus && <StatusItem status={registrationStatus} /> }
        { cnpStatus && <StatusItem status={cnpStatus} /> }
        { calgrantStatus && <CalGrantStatusItem status={calgrantStatus} /> }
      </div>
    );
  }

  return null;
};

const statusProps = PropTypes.shape({
  message: PropTypes.string,
  severity: PropTypes.string,
  detailedMessageHTML: PropTypes.string
});

TermRegistrationStatus.propTypes = {
  termRegistration: PropTypes.shape({
    termName: PropTypes.string,
    termId: PropTypes.string,
    registrationStatus: statusProps,
    cnpStatus: statusProps
  })
};

export default TermRegistrationStatus;
