import NoticeBox from './NoticeBox';
import { connect } from 'react-redux';

const mapStateToProps = ({
  myEnrollments: {
    loaded: enrollmentsLoaded = false,
    enrollmentTerms = [],
  } = {},
}) => {
  return { enrollmentsLoaded, enrollmentTerms, messageKey: 'classInfoMessage' };
};

const ClassInfoMessage = connect(mapStateToProps)(NoticeBox);

export default ClassInfoMessage;
