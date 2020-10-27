import React, { useEffect, useState } from 'react';
import { useParams, useHistory } from 'react-router-dom';
import { Formik } from 'formik';

import Card from 'react/components/Card';

import {
  getServiceAlert,
  updateServiceAlert,
  destroyServiceAlert,
} from 'functions/requests';
import { validationSchema } from './serviceAlert.module.js';

import ServiceAlertForm from './ServiceAlertForm';
import PreviewBox from './PreviewBox';
import ServiceAlert from './ServiceAlert';

export default function EditServiceAlert() {
  const { id } = useParams();
  const [serviceAlert, setServiceAlert] = useState({
    title: '',
  });
  const [loadState, setLoadState] = useState('pending');
  const history = useHistory();

  useEffect(() => {
    getServiceAlert(id).then(data => {
      setServiceAlert(data);
      setLoadState('success');
    });
  }, [id]);

  const onSubmit = (values, { setErrors }) => {
    updateServiceAlert(id, values).then(
      () => {
        alert('Service alert was successfully updated');
      },
      errors => setErrors(errors)
    );
  };

  const destroy = () => {
    const response = confirm(
      'Are you sure you want to delete this service alert?'
    );

    if (response) {
      destroyServiceAlert(id).then(response => {
        if (response.ok) {
          history.push('/service_alerts');
        }
      });
    }
  };

  return (
    <Card
      title="Edit Service Alert"
      loading={loadState === 'pending'}
      secondaryContent={
        <button className="cc-button-link" onClick={destroy}>
          Delete
        </button>
      }
    >
      <Formik
        initialValues={serviceAlert}
        validationSchema={validationSchema}
        onSubmit={onSubmit}
      >
        {formik => (
          <div style={{ display: `flex`, marginTop: `15px` }}>
            <div style={{ flex: `1` }}>
              <ServiceAlertForm />
            </div>

            <PreviewBox style={{ flex: `1`, marginLeft: `15px` }}>
              <ServiceAlert {...formik.values} />
            </PreviewBox>
          </div>
        )}
      </Formik>
    </Card>
  );
}
