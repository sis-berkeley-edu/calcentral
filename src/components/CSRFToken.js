import React from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';
import Helmet from 'react-helmet';

function CSRFToken({ csrfToken }) {
  return (
    <Helmet>
      <meta name="csrf-token" content={csrfToken} />
    </Helmet>
  );
}

CSRFToken.propTypes = {
  csrfToken: PropTypes.string,
};

const mapStateToProps = ({ config: { csrfToken } }) => ({ csrfToken });

export default connect(mapStateToProps)(CSRFToken);
