import { useEffect } from 'react';
import { connect } from 'react-redux';
import { getUserAuth } from 'actions/userAuthActions';

function RequireAuthor({ currentUID, loadAuthentication, isAuthor, children }) {
  useEffect(() => {
    loadAuthentication(currentUID);
  }, [currentUID]);

  if (isAuthor) {
    return children;
  }

  return null;
}

const mapStateToProps = ({ currentUID, users }) => {
  const { userAuth: { is_author: isAuthor, is_superuser: isSuperuser } = {} } =
    users[currentUID] || {};
  return { currentUID, isAuthor: isAuthor || isSuperuser };
};

const mapDispatchToProps = dispatch => ({
  loadAuthentication: uid => dispatch(getUserAuth(uid)),
});

export default connect(
  mapStateToProps,
  mapDispatchToProps
)(RequireAuthor);
