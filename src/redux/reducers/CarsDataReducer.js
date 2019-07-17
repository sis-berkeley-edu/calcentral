import {
  FETCH_CARS_DATA_START,
  FETCH_CARS_DATA_SUCCESS,
  FETCH_CARS_DATA_FAILURE
} from '../actions/carsDataActions';

const CarsDataReducer = (state = {}, action) => {
  switch (action.type) {
    case FETCH_CARS_DATA_START:
      return { ...state, isLoading: true, error: null};
    case FETCH_CARS_DATA_SUCCESS:
      return { ...state, activity: action.value.activity, isLoading: false, loaded: true, error: null };
    case FETCH_CARS_DATA_FAILURE:
      return { ...state, items: state.items.map(item => item.id === action.value ? { ...item, loadingPayments: true } : item)};
    default:
      return state;
  }
};

export default CarsDataReducer;
