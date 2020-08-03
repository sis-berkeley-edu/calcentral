import NoticeBox from './NoticeBox';
import { connect } from 'react-redux';

const mapStateToProps = ({
  myEnrollments: {
    loaded: enrollmentsLoaded = false,
    enrollmentTerms = [],
  } = {},
}) => {
  return { enrollmentsLoaded, enrollmentTerms, messageKey: 'message' };
};

const EnrollmentNotice = connect(mapStateToProps)(NoticeBox);

export default EnrollmentNotice;
