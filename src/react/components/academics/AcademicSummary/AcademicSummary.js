import React, { Component } from 'react';
import { react2angular } from 'react2angular';

import NotFound404 from '../../NotFound404';
import Spinner from '../../Spinner';
import Icon from '../../Icon/Icon';
import { ICON_PRINT } from '../../Icon/IconTypes';

import Enrollment from './Enrollment';
import StudentProfile from '../StudentProfile/StudentProfile';

import './AcademicSummary.scss';

const fetchStatus = () => {
  const STATUS_URL = '/api/my/status';
  return fetch(STATUS_URL).then(data => data.json()).then(json => {
    return { user: json };
  });
};

const fetchAcademics = () => new Promise((resolve) => {
  const PROFILE_URL = '/api/my/profile';
  const ACADEMICS_URL = '/api/my/academics';
  const TRANSFER_CREDIT_URL = '/api/academics/transfer_credits';

  const profile = fetch(PROFILE_URL).then(data => data.json()).then(json => {
    return { studentProfile: json.feed.student };
  });

  const academics = fetch(ACADEMICS_URL).then(data => data.json()).then(json => {
    return { academics: json };
  });

  const transferCredit = fetch(TRANSFER_CREDIT_URL).then(data => data.json()).then(json => {
    return {
      transferCredit: json,
      showTransferCredit: (json.law.detailed || json.graduate.detailed || json.undergraduate.detailed)
    };
  });

  Promise.all([profile, academics, transferCredit]).then((responses) => {
    resolve(responses);
  });
});

class AcademicSummary extends Component {
  constructor(props) {
    super(props);

    this.state = {
      loaded: false
    };
  }

  componentDidMount() {
    fetchStatus().then(response => {
      this.setState(response);

      if (response.user.hasAcademicsTab) {
        fetchAcademics().then((responses) => {
          responses.forEach(response => {
            this.setState(response);
          });
        }).finally(() => {
          this.setState({ loaded: true });
        });
      }
    });
  }

  printPage() {
    window.print();
  }

  showEnrollment() {
    return (this.state.academics.semesters.length && this.state.user.hasStudentHistory) || this.state.showTransferCredit;
  }

  tcReportLink() {
    const links = this.state.academics.studentLinks || this.state.academics.advisorLinks;
    if (links) {
      return links.tcReportLink;
    }
  }

  render() {
    if (!this.state.user) {
      return null;
    }

    if (this.state.user.hasAcademicsTab) {
      return (
        <div className="cc-page-academics">
          <div className="column">
            <h1 className="cc-heading-page-title cc-print-hide">
              <a href="/academics">My Academics</a> &raquo; Academic Summary
            </h1>
          </div>
          <div className="row">
            <div className="medium-10 medium-offset-1 column">
              <div className="cc-widget cc-academic-summary">
                <div className="cc-widget-title">
                  <h2 className="cc-left">Academic Summary</h2>
                  <button className="cc-button cc-button-blue cc-right cc-widget-title-button" onClick={this.printPage}>
                    <Icon name={ICON_PRINT} /> Print
                  </button>
                </div>

                {this.state.loaded
                  ? (
                    <div className="AcademicSummary__body">
                      <h3>Student Profile</h3>
                      <StudentProfile
                        studentProfile={this.state.studentProfile}
                        academics={this.state.academics}
                        user={this.state.user}
                      />
                      {this.showEnrollment() &&
                        <Enrollment
                          gpaUnits={this.state.academics.gpaUnits}
                          semesters={this.state.academics.semesters}
                          user={this.state.user}
                          transferCredit={this.state.transferCredit}
                          transferReportLink={this.tcReportLink()}
                        />
                      }
                    </div>
                  )
                  : <Spinner />
                }
              </div>
            </div>
          </div>
        </div>
      );
    } else {
      return <NotFound404 />;
    }
  }
}

angular.module('calcentral.react').component('academicSummary', react2angular(AcademicSummary));

export default AcademicSummary;
