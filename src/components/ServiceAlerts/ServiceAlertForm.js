import React from 'react';
import { Field } from 'formik';
import { Link } from 'react-router-dom';

import Form from 'components/Form';
import FieldWrapper from 'components/FieldWrapper';
import FieldError from 'components/FieldError';

export default function ServiceAlertForm() {
  return (
    <Form>
      <FieldWrapper>
        <label htmlFor="title">Title</label>
        <Field id="title" name="title" style={{ width: `100%` }} />
        <FieldError name="title" />
      </FieldWrapper>

      <FieldWrapper>
        <label htmlFor="body">Body HTML</label>
        <Field as="textarea" id="body" name="body" />
        <FieldError name="body" />
      </FieldWrapper>

      <FieldWrapper>
        <label htmlFor="publication_date">Publication Date</label>
        <Field
          id="publication_date"
          name="publication_date"
          placeholder="YYYY-MM-DD"
        />
        <FieldError name="publication_date" />
      </FieldWrapper>

      <FieldWrapper type="checkbox">
        <Field type="checkbox" name="display" id="display" />
        <label htmlFor="display">Display</label>
      </FieldWrapper>

      <FieldWrapper type="checkbox">
        <Field type="checkbox" name="splash_only" id="splash_only" />
        <label htmlFor="splash_only">Splash only</label>
      </FieldWrapper>

      <FieldWrapper type="checkbox">
        <input type="submit" value="Save" />
        <Link to="/service_alerts" style={{ marginLeft: `15px` }}>
          cancel
        </Link>
      </FieldWrapper>
    </Form>
  );
}
