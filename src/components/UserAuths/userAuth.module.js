import * as Yup from 'yup';
import PropTypes from 'prop-types';

export const validationSchema = Yup.object({
  uid: Yup.string().required('Required'),
});

export const propTypes = {
  id: PropTypes.number,
  active: PropTypes.bool,
  viewer: PropTypes.bool,
  author: PropTypes.bool,
  superuser: PropTypes.bool,
};

export const propShape = PropTypes.shape(propTypes);
