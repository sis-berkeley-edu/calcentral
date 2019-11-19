import React from 'react';
import PropTypes from 'prop-types';
import APILink from 'React/components/APILink';
import HasAccessTo from './HasAccessTo';
import './FinancialResources.scss';

const HaveAQuestion = ({ links, getLink }) => {
  return (
    <HasAccessTo linkNames={['calStudentCentral']} links={links}>
      <div className="FinancialResources__questionContainer">
        <h3>Have a question?</h3>
        <p>
          <APILink {...getLink('calStudentCentral', links)} />
        </p>
      </div>
    </HasAccessTo>
  );
};

HaveAQuestion.propTypes = {
  getLink: PropTypes.func,
  links: PropTypes.object,
};

export default HaveAQuestion;
