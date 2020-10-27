import React from 'react';
import { useHistory } from 'react-router-dom';
import { Formik } from 'formik';
import Card from 'react/components/Card';

import { LargeSpacer } from 'components/VerticalSpacers';

import { validationSchema } from './userAuth.module.js';
import { createUserAuth } from 'functions/requests';
import UserAuthForm from './UserAuthForm.js';

export default function NewUserAuth() {
  const history = useHistory();
  const initialValues = {
    uid: '',
    is_active: true,
    is_viewer: false,
    is_author: false,
    is_superuser: false,
  };

  const onSubmit = (values, { setErrors }) => {
    createUserAuth(values)
      .then(response => {
        return response.json().then(data => ({
          data,
          response,
        }));
      })
      .then(({ data, response }) => {
        if (response.ok) {
          history.push(`/api/service_alerts/${data.id}`);
        } else if (response.status === 422) {
          setErrors(data);
        }
      });
  };

  return (
    <Card title="New User Auth">
      <LargeSpacer />
      <Formik
        initialValues={initialValues}
        onSubmit={onSubmit}
        validationSchema={validationSchema}
      >
        <UserAuthForm />
      </Formik>
    </Card>
  );
}
