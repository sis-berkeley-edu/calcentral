import React from 'react';
import { useHistory } from 'react-router-dom';
import { Formik } from 'formik';
import Card from 'react/components/Card';
import ServiceAlertForm from './ServiceAlertForm';
import PreviewBox from './PreviewBox';
import ServiceAlert from './ServiceAlert';

import { validationSchema } from './serviceAlert.module.js';
import { createServiceAlert } from '../../functions/requests';

export default function NewServiceAlert() {
  const history = useHistory();

  return (
    <Card title="New Service Alert">
      <Formik
        initialValues={{
          title: '',
          body: '',
          publication_date: '',
          display: true,
          splash_only: true,
        }}
        validationSchema={validationSchema}
        onSubmit={(values, { setErrors }) => {
          createServiceAlert(values).then(
            data => {
              history.push(`/api/service_alerts/${data.id}`);
            },
            errors => setErrors(errors)
          );
        }}
      >
        {formik => (
          <div style={{ display: `flex`, marginTop: `15px` }}>
            <div style={{ flex: `1` }}>
              <ServiceAlertForm formik={formik} />
            </div>
            <div style={{ flex: `1` }}>
              <PreviewBox style={{ flex: `1`, marginLeft: `15px` }}>
                <ServiceAlert {...formik.values} />
              </PreviewBox>
            </div>
          </div>
        )}
      </Formik>
    </Card>
  );
}
