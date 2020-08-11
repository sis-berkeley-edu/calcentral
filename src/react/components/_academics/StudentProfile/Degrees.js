import React, { Fragment } from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';

import { format, parseISO } from 'date-fns';
import Icon from '../../Icon/Icon';
import { ICON_GRADUATION, ICON_CERTIFICATE } from '../../Icon/IconTypes';

import './Degrees.scss';

const college = degree => degree.plans[0].college;
const LAW_LLM = "28";
const LAW_JSD = "69";
const description = degree => (degree.academicDegree.type.code == LAW_LLM) ? "" : degree.academicDegree.type.description;
const inWord = degree => (degree.academicDegree.type.code == LAW_LLM || degree.academicDegree.type.code == LAW_JSD) ? "" : "in";
const degreeMajors = degree =>
  (degree.academicDegree.type.code == 'LAW_JSD') ? "" : (degree.majors.map(major => major.description).join(', '));

const formattedAwardDate = degree => {
  return format(parseISO(degree.dateAwarded), 'MMMM d, y');
};

const Degree = ({ degree, index }) => {
  const honors = degree.honors || [];

  return (
    <div className="Degree" key={index}>
      <div className="Degree__icon-container">
        {degree.majors[0].type === 'CRT' ? (
          <Icon name={ICON_CERTIFICATE} />
        ) : (
          <Icon name={ICON_GRADUATION} />
        )}
      </div>
      <div className="Degree__body">
        <div className="Degree__description">
          {description(degree)} <span>{inWord(degree)}</span> {degreeMajors(degree)}
        </div>

        {degree.designatedEmphases.length > 0 && (
          <div className="Degree__emphases">
            {degree.designatedEmphases.map((emphasis, index) => (
              <span key={index}>{emphasis.description}</span>
            ))}
          </div>
        )}

        <div className="Degree__awarded-on">
          Awarded: {formattedAwardDate(degree)}
        </div>

        {degree.isUndergrad && (
          <Fragment>
            <div>{college(degree)}</div>

            {honors.map((honor, index) => (
              <div key={index}>{honor.formalDescription}</div>
            ))}

            {degree.minors.map((minor, index) => (
              <div key={index}>{minor.description}</div>
            ))}
          </Fragment>
        )}
      </div>
    </div>
  );
};

Degree.displayName = 'Degree';
Degree.propTypes = {
  degree: PropTypes.object,
  index: PropTypes.number,
};

const Degrees = ({ degrees }) => {
  if (degrees.length) {
    return (
      <tr>
        <th>{degrees.length === 1 ? 'Degree' : 'Degrees'} Conferred</th>
        <td>
          {degrees.map((degree, index) => (
            <Degree key={index} degree={degree} index={index} />
          ))}
        </td>
      </tr>
    );
  } else {
    return null;
  }
};

Degrees.displayName = 'Degrees';
Degrees.propTypes = {
  degrees: PropTypes.array.isRequired,
};

const mapStateToProps = ({ myAcademics = {} }) => {
  const { collegeAndLevel: { degrees = [] } = {} } = myAcademics;

  return {
    degrees: degrees || [],
  };
};

export default connect(mapStateToProps)(Degrees);
