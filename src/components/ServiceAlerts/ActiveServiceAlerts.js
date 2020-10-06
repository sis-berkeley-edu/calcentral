import React, { useEffect, useState } from 'react';

import { Link } from 'react-router-dom';
import Card from 'react/components/Card';

import { getDisplayedServiceAlerts } from 'functions/requests';
import { propShape } from './serviceAlert.module.js';

const ServiceAlert = ({ serviceAlert }) => (
  <div style={{ marginTop: `15px` }}>
    <Link to={`/service_alerts/${serviceAlert.id}/edit`}>
      {serviceAlert.title}
    </Link>
  </div>
);

ServiceAlert.propTypes = {
  serviceAlert: propShape,
};

export default function ActiveServiceAlerts() {
  const [serviceAlerts, setServiceAlerts] = useState([]);
  const [loadState, setLoadState] = useState('pending');

  useEffect(() => {
    getDisplayedServiceAlerts().then(data => {
      setServiceAlerts(data.service_alerts);
      setLoadState('success');
    });
  }, []);

  return (
    <Card
      title="Active Service Alerts"
      loading={loadState === 'pending'}
      secondaryContent={<Link to="/service_alerts">All Service Alerts</Link>}
    >
      {serviceAlerts.map(alert => (
        <ServiceAlert key={alert.id} serviceAlert={alert} />
      ))}
    </Card>
  );
}
