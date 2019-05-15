import {
  FETCH_LINK_START,
  FETCH_LINK_SUCCESS
} from '../actions/linksActions';

const LinksReducer = (state = {}, action) => {
  switch (action.type) {
    case FETCH_LINK_START:
      state[action.key] = { loading: true };
      return state;
    case FETCH_LINK_SUCCESS:
      state[action.key] = { ...action.value, loaded: true, loading: false };
      return state;
    default:
      return state;
  }
};

export default LinksReducer;
