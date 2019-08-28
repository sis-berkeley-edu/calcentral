import React from 'react';

import GreenCheckCircle from 'React/components/Icon/GreenCheckCircle';
import YellowWarningSign from 'React/components/Icon/YellowWarningSign';
import RedExclamationIcon from 'React/components/Icon/RedExclamationIcon';

const RegistrationStatusIcon = ({ severity }) => {
  switch (severity) {
    case 'normal':
      return <GreenCheckCircle style={{ marginRight: '5px' }} />;
    case 'notice':
      return <YellowWarningSign style={{ marginRight: '4px' }} />;
    case 'warning':
      return <RedExclamationIcon />;
    default:
      return null;
  }
};

export default RegistrationStatusIcon;
