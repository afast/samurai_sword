
import {makeRequest, makeAuthenticatedRequest} from './utils';
const API_URL = 'http://localhost:3000';

export const recoverResistance = (id) => {
  return makeAuthenticatedRequest(`${API_URL}/games/${id}/reset_resistance.json`, {method: 'POST'})
}

export const takeCards = (id) => {
  return makeAuthenticatedRequest(`${API_URL}/games/${id}/take_cards.json`, { method: 'POST' })
}

export const playCard = (id, player, card, target) => {
  return makeAuthenticatedRequest(`${API_URL}/games/${id}/play_card.json`, { method: 'POST', body: JSON.stringify({
    player: player.character,
    card: card.name,
    target: target
  }) })
}

export const answerCard = (id) => {
  return makeAuthenticatedRequest(`${API_URL}/games/${id}/answer_card.json`, { method: 'POST' })
}

export const discardCard = (id) => {
  return makeAuthenticatedRequest(`${API_URL}/games/${id}/discard_cards.json`, { method: 'POST' })
}

export const endTurn = (id) => {
  return makeAuthenticatedRequest(`${API_URL}/games/${id}/end_turn.json`, { method: 'POST' })
}

export const loadGame = (id) => {
  return makeAuthenticatedRequest(`${API_URL}/games/${id}.json`, { method: 'POST' })
}

export default {
  recoverResistance,
  takeCards,
  playCard,
  answerCard,
  discardCard,
  endTurn,
  loadGame,
}
