import React from 'react';

const NotFound404 = () => (
  <div className="cc-page-status">
    <h1 className="cc-visuallyhidden">Page not found</h1>
    <div className="cc-widget cc-page-status-container">
      <div className="cc-widget-title">
        <h2>Oops!</h2>
      </div>
      <div className="cc-widget-padding">
        <div className="cc-left cc-page-status-container-text">
          <h3>Cannot Find That Page</h3>
          <p>
            For some reason CalCentral is unable to find the page you requested.
            To go to CalCentral, click the button below.
            To report a missing page, click the <a href="https://sis.berkeley.edu/help/report-issue">Feedback</a> link.
          </p>
        </div>
        <div className="cc-right cc-page-status-magnifying"></div>
        <a href="/dashboard" className="cc-button cc-button-blue cc-page-status-button">Go To Dashboard</a>
      </div>
    </div>
  </div>
);

export default NotFound404;
