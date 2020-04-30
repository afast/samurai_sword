import api from '../api/index';

export const actionTypes = {
  RECOVER_RESISTANCE: 'RECOVER_RESISTANCE',
  RECOVER_RESISTANCE_SUCCESS: 'RECOVER_RESISTANCE_SUCCESS',
  TAKE_CARDS: 'TAKE_CARDS',
  TAKE_CARDS_SUCCESS: 'TAKE_CARDS_SUCCESS',
  PLAY_CARD: 'PLAY_CARD',
  PLAY_CARD_SUCCESS: 'PLAY_CARD_SUCCESS',
  ANSWER_CARD: 'ANSWER_CARD',
  ANSWER_CARD_SUCCESS: 'ANSWER_CARD_SUCCESS',
  DISCARD_CARD: 'DISCARD_CARD',
  DISCARD_CARD_SUCCESS: 'DISCARD_CARD_SUCCESS',
  END_TURN: 'END_TURN',
  END_TURN_SUCCESS: 'END_TURN_SUCCESS',
  LOAD_GAME: 'GET_GAME',
  LOAD_GAME_SUCCESS: 'LOAD_GAME_SUCCESS',
  WANTS_TO_PLAY: 'WANTS_TO_PLAY',
  SET_CURRENT_USER: 'SET_CURRENT_USER',
  ACTION_FAILURE: 'ACTION_FAILURE'
};

export const recoverResistance = (id) => (dispatch, getState) => {
  api.recoverResistance(id)
    .then(data => dispatch({type: actionTypes.RECOVER_RESISTANCE_SUCCESS, data}))
    .catch(error => dispatch({type: actionTypes.ACTION_FAILURE, error}));
};

export const takeCards = (id) => (dispatch, getState) => {
  api.takeCards(id)
    .then(data => dispatch({type: actionTypes.TAKE_CARDS_SUCCESS, data}))
    .catch(error => dispatch({type: actionTypes.ACTION_FAILURE, error}));
};

export const playCard = (player, card_name, target) => (dispatch, getState) => {
  const game = getState().game;
  api.playCard(game.id, player, card_name, target)
    .then(data => dispatch({type: actionTypes.PLAY_CARD_SUCCESS, data}))
    .catch(error => dispatch({type: actionTypes.ACTION_FAILURE, error}));
};

export const answerCard = (id) => (dispatch, getState) => {
  api.answerCard(id)
    .then(data => dispatch({type: actionTypes.ANSWER_CARD_SUCCESS, data}))
    .catch(error => dispatch({type: actionTypes.ACTION_FAILURE, error}));
};

export const discardCard = (id) => (dispatch, getState) => {
  api.discardCard(id)
    .then(data => dispatch({type: actionTypes.DISCARD_CARD_SUCCESS, data}))
    .catch(error => dispatch({type: actionTypes.ACTION_FAILURE, error}));
};

export const endTurn = (id) => (dispatch, getState) => {
  api.endTurn(id)
    .then(data => dispatch({type: actionTypes.END_TURN_SUCCESS, data}))
    .catch(error => dispatch({type: actionTypes.ACTION_FAILURE, error}));
};

export const loadGame = (id) => (dispatch, getState) => {
  api.loadGame(id)
    .then(data => dispatch({type: actionTypes.LOAD_GAME_SUCCESS, data}))
    .catch(error => dispatch({type: actionTypes.ACTION_FAILURE, error}));
};

export const loadGameSuccess = (game) => {
  return {type: actionTypes.LOAD_GAME_SUCCESS, data: game};
}

export const setCurrentUser = (user) => {
  return {type: actionTypes.SET_CURRENT_USER, data: user}
}

export const wantsToPlay = (card) => {
  return {type: actionTypes.WANTS_TO_PLAY, data: card};
}

export default {
  recoverResistance,
  takeCards,
  playCard,
  answerCard,
  discardCard,
  endTurn,
  loadGame,
  wantsToPlay,
  setCurrentUser,
  loadGameSuccess
};