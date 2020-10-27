import React, { useEffect, useState } from 'react';
import { useParams } from 'react-router-dom';
import { Formik } from 'formik';

import Card from 'react/components/Card';
import { LargeSpacer } from 'components/VerticalSpacers';
import UserAuthForm from './UserAuthForm';
import { updateUserAuth, destroyUserAuth } from '../../functions/requests';

export default function EditUserAuth() {
  const { id } = useParams();
  const [userAuth, setUserAuth] = useState({});
  const [loadState, setLoadState] = useState('pending');

  useEffect(() => {
    fetch(`/api/user_auths/${id}`)
      .then(response => response.json())
      .then(data => {
        setUserAuth(data);
        setLoadState('success');
      });
  }, [id]);

  const onSubmit = values => {
    updateUserAuth(id, values).then(response => response.json());
  };

  const destroy = () => {
    const response = confirm(
      'Are you sure you want to delete this service alert?'
    );

    if (response) {
      destroyUserAuth(id).then(response => {
        if (response.ok) {
          history.push('/service_alerts');
        }
      });
    }
  };

  return (
    <Card
      title="Edit User Auth"
      loading={loadState === 'pending'}
      secondaryContent={
        <button className="cc-button-link" onClick={destroy}>
          Delete
        </button>
      }
    >
      <LargeSpacer />
      <Formik initialValues={userAuth} onSubmit={onSubmit}>
        <UserAuthForm />
      </Formik>
    </Card>
  );
}
