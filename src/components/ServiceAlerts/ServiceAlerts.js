import React, { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import Card from 'react/components/Card';

import Table from 'components/Table';
import { propShape } from './serviceAlert.module.js';

import { getServiceAlerts } from 'functions/requests';

const ServiceAlertRow = ({
  serviceAlert: { id, title, publication_date, splash_only, display },
}) => (
  <tr>
    <td>
      <Link to={`/service_alerts/${id}/edit`}>{title}</Link>
    </td>
    <td>{publication_date}</td>
    <td>{splash_only ? 'true' : null}</td>
    <td>{display ? 'true' : null}</td>
  </tr>
);

ServiceAlertRow.propTypes = { serviceAlert: propShape };

export default function ServiceAlerts() {
  const [serviceAlerts, setServiceAlerts] = useState([]);
  const [loadState, setLoadState] = useState('pending');

  useEffect(() => {
    getServiceAlerts().then(data => {
      setServiceAlerts(data.service_alerts);
      setLoadState('success');
    });
  }, []);

  return (
    <Card
      title="Service Alerts"
      loading={loadState === 'pending'}
      secondaryContent={<Link to="/service_alerts/new">New Service Alert</Link>}
    >
      <div style={{ marginTop: `15px` }} />
      <Table>
        <thead>
          <tr>
            <th>Title</th>
            <th>Pub. Date</th>
            <th>Splash Only</th>
            <th>Display</th>
          </tr>
        </thead>
        <tbody>
          {serviceAlerts.map(alert => (
            <ServiceAlertRow key={alert.id} serviceAlert={alert} />
          ))}
        </tbody>
      </Table>
    </Card>
  );
}
