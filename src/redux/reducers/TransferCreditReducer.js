import {
  FETCH_TRANSFER_CREDIT_START,
  FETCH_TRANSFER_CREDIT_SUCCESS,
  FETCH_TRANSFER_CREDIT_FAILURE
} from '../actions/transferCreditActions';

const TransferCreditReducer = (state = {}, action) => {
  switch (action.type) {
    case FETCH_TRANSFER_CREDIT_START:
      return { ...state, isLoading: true, error: null };
    case FETCH_TRANSFER_CREDIT_SUCCESS:
      return { ...state, ...action.value, loaded: true, isLoading: false, error: null };
    case FETCH_TRANSFER_CREDIT_FAILURE:
      return { ...state, isLoading: false, error: action.value };
    default:
      return state;
  }
};

export default TransferCreditReducer;
