import { actionTypes } from '../actions/game';

const ACTION_HANDLERS = {
  [actionTypes.RECOVER_RESISTANCE_SUCCESS]: (state, action) => (
    {...state, game: action.data}
  ),
  [actionTypes.TAKE_CARDS_SUCCESS]: (state, action) => (
    {...state, game: action.data}
  ),
  [actionTypes.PLAY_CARD_SUCCESS]: (state, action) => {
    return {...state, game: action.data, wantsToPlay: {}}
  },
  [actionTypes.ANSWER_CARD_SUCCESS]: (state, action) => (
    {...state, game: action.data, wantsToPlay: {}}
  ),
  [actionTypes.DISCARD_CARD_SUCCESS]: (state, action) => (
    {...state, game: action.data, wantsToPlay: {}}
  ),
  [actionTypes.END_TURN_SUCCESS]: (state, action) => (
    {...state, game: action.data, wantsToPlay: {}}
  ),
  [actionTypes.LOAD_GAME_SUCCESS]: (state, action) => (
    {...state, game: action.data}
  ),
  [actionTypes.WANTS_TO_PLAY]: (state, action) => (
    {...state, wantsToPlay: action.data}
  ),
  [actionTypes.SET_CURRENT_USER]: (state, action) => (
    {...state, currentUser: action.data}
  ),
  [actionTypes.CLEAN_WANTS_TO_PLAY]: (state, action) => (
    {...state, wantsToPlay: {}}
  ),
  [actionTypes.ACTION_FAILURE]: (state, action) => (
    {...state, wantsToPlay: {}}
  )
}

const initialState = {
};

const gameReducer = (state = initialState, action) => {
  const handler = ACTION_HANDLERS[action.type];

  return handler ? handler(state, action) : state;
};

export default gameReducer
