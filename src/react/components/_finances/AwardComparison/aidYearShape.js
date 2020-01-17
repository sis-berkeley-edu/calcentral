import PropTypes from 'prop-types';

const aidYearShape = PropTypes.shape({
  cost: PropTypes.shape({
    total: PropTypes.number,
    items: PropTypes.arrayOf(
      PropTypes.shape({
        description: PropTypes.string,
        value: PropTypes.number,
      })
    ),
  }),
});

export default aidYearShape;
