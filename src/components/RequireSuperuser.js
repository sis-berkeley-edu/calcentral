import { useEffect } from 'react';
import { connect } from 'react-redux';
import { getUserAuth } from 'actions/userAuthActions';

function RequireSuperuser({
  currentUID,
  loadAuthentication,
  isSuperuser,
  children,
}) {
  useEffect(() => {
    loadAuthentication(currentUID);
  }, [currentUID]);

  if (isSuperuser) {
    return children;
  }

  return null;
}

const mapStateToProps = ({ currentUID, users }) => {
  const { userAuth: { is_superuser: isSuperuser } = {} } =
    users[currentUID] || {};
  return { currentUID, isSuperuser };
};

const mapDispatchToProps = dispatch => ({
  loadAuthentication: uid => dispatch(getUserAuth(uid)),
});

export default connect(
  mapStateToProps,
  mapDispatchToProps
)(RequireSuperuser);
