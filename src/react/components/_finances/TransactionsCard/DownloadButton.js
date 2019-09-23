import React from 'react';

import './DownloadButton.scss';

const DownloadButton = () => {
  const onClick = () => {
    document.location.pathname = '/api/my/finances/billing_items.csv';
  };

  return (
    <div className="DownloadButton" onClick={() => onClick()}>
      Download
    </div>
  );
};

export default DownloadButton;
