import React, { useState } from 'react';
import { Link } from 'react-router-dom';
import { Formik, Field } from 'formik';
import Card from 'react/components/Card';
import Form from 'components/Form';
import FieldWrapper from 'components/FieldWrapper';
import FormActions from 'components/FormActions';
import { LargeSpacer } from 'components/VerticalSpacers';
import { findUserAuth } from 'functions/requests';
import UserAuthsTable from './UserAuthsTable';

import RequireSuperuser from 'components/RequireSuperuser';

export default function FindUserAuth() {
  const [userAuths, setUserAuths] = useState([]);
  const [loadState, setLoadState] = useState('');

  const onSubmit = values => {
    setLoadState('pending');
    findUserAuth(values.uid).then(
      data => {
        setUserAuths(data.user_auths);
        setLoadState('success');
      },
      _errors => setLoadState('failure')
    );
  };

  return (
    <RequireSuperuser>
      <Card
        title="User Auths"
        secondaryContent={<Link to="/user_auths">All User Auths</Link>}
      >
        <Formik initialValues={{ uid: '' }} onSubmit={onSubmit}>
          <Form>
            <FieldWrapper>
              <label htmlFor="uid">UID</label>
              <Field name="uid" />
            </FieldWrapper>

            <FormActions>
              <input type="submit" value="Search" />
            </FormActions>
          </Form>
        </Formik>

        <LargeSpacer />

        {loadState === 'failure' && 'An erroroccurred!'}
        {loadState === 'pending' && 'Searching...'}
        {loadState === 'success' &&
          (userAuths.length > 0 ? (
            <UserAuthsTable userAuths={userAuths} />
          ) : (
            <p>No user auth was found for that UID.</p>
          ))}
      </Card>
    </RequireSuperuser>
  );
}
