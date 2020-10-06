import React from 'react';
import { Link } from 'react-router-dom';
import { Field } from 'formik';
import Form from 'components/Form';
import FormActions from 'components/FormActions';
import FieldWrapper from 'components/FieldWrapper';

const UserAuthForm = () => (
  <Form>
    <Field name="uid" />
    <FieldWrapper type="checkbox">
      <Field name="is_active" id="is_active" type="checkbox" />
      <label htmlFor="is_active">Active</label>
    </FieldWrapper>
    <FieldWrapper type="checkbox">
      <Field name="is_viewer" id="is_viewer" type="checkbox" />
      <label htmlFor="is_viewer">Viewer</label>
    </FieldWrapper>
    <FieldWrapper type="checkbox">
      <Field name="is_author" id="is_author" type="checkbox" />
      <label htmlFor="is_author">Author</label>
    </FieldWrapper>
    <FieldWrapper type="checkbox">
      <Field name="is_superuser" id="is_superuser" type="checkbox" />
      <label htmlFor="is_superuser">Superuser?</label>
    </FieldWrapper>
    <FormActions>
      <input type="submit" value="Save" />
      <Link to="/user_auths">cancel</Link>
    </FormActions>
  </Form>
);

export default UserAuthForm;
