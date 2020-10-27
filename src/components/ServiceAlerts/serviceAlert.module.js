import * as Yup from 'yup';
import PropTypes from 'prop-types';

export const validationSchema = Yup.object({
  title: Yup.string().required('Required'),
  body: Yup.string().required('Required'),
  publication_date: Yup.date()
    .required('Required')
    .typeError('is invalid'),
});

export const propTypes = {
  id: PropTypes.number,
  title: PropTypes.string,
  body: PropTypes.string,
  publication_date: PropTypes.string,
  display: PropTypes.bool,
  splash_only: PropTypes.bool,
};

export const propShape = PropTypes.shape(propTypes);

export function getCSRFToken() {
  return document
    .querySelector('meta[name=csrf-token]')
    .getAttribute('content');
}
