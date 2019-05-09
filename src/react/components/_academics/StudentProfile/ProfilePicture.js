import React, { useState } from 'react';

import './ProfilePicture.scss';
import MissingPhoto from './MissingPhoto';

const ProfilePicture = (props) => {
  const [error, setError] = useState(false);
  const { isDelegate, fullName } = props;

  if (isDelegate) {
    return (
      <div className="cc-widget-delegate-student-img ng-scope"
        alt={`${fullName}'s photo`} />
    );
  } else if (error) {
    return (<MissingPhoto />);
  } else {
    return (
      <img src="/api/my/photo"
        alt={`${fullName}'s Profile Picture`}
        onError={() => setError(true)} width="72" height="96" />
    );
  }
};

export default ProfilePicture;
