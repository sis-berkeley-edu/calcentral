import {
  FETCH_MY_UP_NEXT_START,
  FETCH_MY_UP_NEXT_SUCCESS,
  FETCH_MY_UP_NEXT_FAILURE,
  TOGGLE_MY_UP_NEXT,
} from '../actions/myUpNextActions';

const toggleUpNextItem = (state, action) => {
  let newItems = state.items.map((item, index) => {
    // set as false if not the toggled item
    if (index !== action.index) {
      return { ...item, show: false };
    }
    // reverse the expanded state of the item clicked on
    return { ...item, show: !item.show };
  });
  return { ...state, items: newItems };
};

const MyUpNextReducer = (state = {}, action) => {
  switch (action.type) {
    case FETCH_MY_UP_NEXT_START:
      return { ...state, isLoading: true, error: null };
    case FETCH_MY_UP_NEXT_SUCCESS:
      return {
        ...state,
        ...action.value,
        loaded: true,
        isLoading: false,
        error: null,
      };
    case FETCH_MY_UP_NEXT_FAILURE:
      return { ...state, loaded: true, isLoading: false, error: action.value };
    case TOGGLE_MY_UP_NEXT:
      return toggleUpNextItem(state, action);
    default:
      return state;
  }
};

export default MyUpNextReducer;
