import React, { Fragment } from 'react';
import PropTypes from 'prop-types';
import format from 'date-fns/format';
import Icon from '../../Icon/Icon';
import { ICON_GRADUATION, ICON_CERTIFICATE } from '../../Icon/IconTypes';

import './Degrees.scss';

const college = (degree) => degree.plans[0].college;
const description = (degree) => degree.academicDegree.type.description;
const degreeMajors = (degree) => degree.majors.map(major => major.description).join(', ');
const formattedAwardDate = (degree) => format(degree.dateAwarded, 'MMMM D, YYYY');

const propTypes = {
  degrees: PropTypes.array
};

const Degrees = (props) => {
  const degrees = props.degrees || [];
  const honors = (degree) => (degree.honors && degree.honors.honors) || [];

  return (
    <tr>
      <th>
        {degrees.length === 1 ? 'Degree' : 'Degrees'} Conferred
      </th>
      <td>
        {degrees.map((degree, index) => (
          <div className="Degree" key={index}>
            <div className="Degree__icon-container">
              {degree.majors[0].type === 'CRT'
                ? <Icon name={ICON_CERTIFICATE} /> 
                : <Icon name={ICON_GRADUATION} />
              }
            </div>
            <div className="Degree__body">
              <div className="Degree__description">
                {description(degree)} <span>in</span> {degreeMajors(degree)}
              </div>

              {degree.designatedEmphases.length > 0 &&
                <div className="Degree__emphases">
                  {degree.designatedEmphases.map((emphasis, index) => (
                    <span key={index}>{emphasis.description}</span>
                  ))}
                </div>
              }

              <div className="Degree__awarded-on">
                Awarded: {formattedAwardDate(degree)}
              </div>

              {degree.isUndergrad &&
                <Fragment>
                  <div>{college(degree)}</div>

                  {honors(degree).map((honor, index) => (
                    <div key={index}>{honor.formalDescription}</div>
                  ))}

                  {degree.minors.map((minor, index) => (
                    <div key={index}>{minor.description}</div>
                  ))}
                </Fragment>
              }
            </div>
          </div>
        ))}
      </td>
    </tr>
  );
};

Degrees.propTypes = propTypes;

export default Degrees;
