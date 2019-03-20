import React from 'react';
import PropTypes from 'prop-types';
import format from 'date-fns/format';
import './AppointmentRow.scss';

const propTypes = {
  description: PropTypes.string.isRequired,
  jobCode: PropTypes.string,
  unit: PropTypes.string,
  step: PropTypes.string,
  startDate: PropTypes.string.isRequired,
  endDate: PropTypes.string.isRequired,
  compenstation: PropTypes.string,
  distributionPercentage: PropTypes.string
};

class AppointmentRow extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      expanded: false
    };
  }

  toggleExpansion() {
    this.setState({ expanded: !this.state.expanded });
  }

  startDate() {
    return format(this.props.startDate, 'MM/DD/YY');
  }

  endDate() {
    return format(this.props.endDate, 'MM/DD/YY');
  }
  
  render() {
    return (
      <div className="AppointmentRow" onClick={() => this.toggleExpansion(this) }>
        <div className="AppointmentRow__header">
          <div className="AppointmentRow__description">
            { this.props.description }
          </div>
          <div className="AppointmentRow__range">
            { this.startDate() } - { this.endDate() }
          </div>
        </div>

        { this.state.expanded ? <div>
          Job Code {this.props.jobCode}
          <table className="AppointmentRow__DataTable">
            <thead>
              <tr>
                <th>Unit</th>
                <th>Step</th>
                <th className="alignRight">Pay</th>
                <th className="alignRight">Distribution</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td>{ this.props.unit }</td>
                <td>{ parseInt(this.props.step) }</td>
                <td className="alignRight">${ parseFloat(this.props.compenstation).toFixed(2) }</td>
                <td className="alignRight">{ parseFloat(this.props.distributionPercentage).toFixed(2) }%</td>
              </tr>
            </tbody>
          </table>
        </div> : <React.Fragment></React.Fragment>
        }
      </div>
    );
  }
}

AppointmentRow.propTypes = propTypes;

export default AppointmentRow;
