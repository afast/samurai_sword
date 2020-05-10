
import {makeRequest, makeAuthenticatedRequest} from './utils';
const API_URL = `${window.location.protocol}//${window.location.host}`

export const recoverResistance = (id) => {
  return makeAuthenticatedRequest(`${API_URL}/games/${id}/reset_resistance.json`, {method: 'POST'})
}

export const takeCards = (id) => {
  return makeAuthenticatedRequest(`${API_URL}/games/${id}/take_cards.json`, { method: 'POST' })
}

export const ieyasuTakeCards = (id) => {
  return makeAuthenticatedRequest(`${API_URL}/games/${id}/ieyasu_take_cards.json`, { method: 'POST' })
}

export const nobunagaTakeCard = (id) => {
  return makeAuthenticatedRequest(`${API_URL}/games/${id}/nobunaga_take_card.json`, { method: 'POST' })
}

export const playCard = (id, player, card, target, geisha) => {
  return makeAuthenticatedRequest(`${API_URL}/games/${id}/play_card.json`, { method: 'POST', body: JSON.stringify({
    player: player.character,
    card: card.name,
    target: target,
    geisha: geisha,
  }) })
}

export const answerCard = (id) => {
  return makeAuthenticatedRequest(`${API_URL}/games/${id}/answer_card.json`, { method: 'POST' })
}

export const discardCard = (id, card_name) => {
  return makeAuthenticatedRequest(`${API_URL}/games/${id}/discard_card.json`, { method: 'POST', body: JSON.stringify({
    card_name: card_name
  }) })
}

export const discardWeapon = (id, character, card_name) => {
  return makeAuthenticatedRequest(`${API_URL}/games/${id}/discard_weapon.json`, { method: 'POST', body: JSON.stringify({
    character: character,
    card_name: card_name
  }) })
}

export const hanzoAbility = (id, character, card_name) => {
  return makeAuthenticatedRequest(`${API_URL}/games/${id}/hanzo_ability.json`, { method: 'POST', body: JSON.stringify({
    character: character,
    card_name: card_name
  }) })
}

export const defendBushido = (id, character, card_name) => {
  return makeAuthenticatedRequest(`${API_URL}/games/${id}/defend_bushido.json`, { method: 'POST', body: JSON.stringify({
    character: character,
    card_name: card_name
  }) })
}

export const endTurn = (id) => {
  return makeAuthenticatedRequest(`${API_URL}/games/${id}/end_turn.json`, { method: 'POST' })
}

export const loadGame = (id) => {
  return makeAuthenticatedRequest(`${API_URL}/games/${id}.json`)
}

export const takeDamage = (id, character) => {
  return makeAuthenticatedRequest(`${API_URL}/games/${id}/take_damage.json`, { method: 'POST', body: JSON.stringify({
    character: character
  }) })
}

export const playStop = (id, character) => {
  return makeAuthenticatedRequest(`${API_URL}/games/${id}/play_stop.json`, { method: 'POST', body: JSON.stringify({
    character: character
  }) })
}

export const joinGame = (id) => {
  return makeAuthenticatedRequest(`${API_URL}/games/${id}/join.json`, { method: 'POST' })
}

export const startGame = (id) => {
  return makeAuthenticatedRequest(`${API_URL}/games/${id}/start.json`, { method: 'POST' })
}

export default {
  recoverResistance,
  takeCards,
  ieyasuTakeCards,
  nobunagaTakeCard,
  playCard,
  answerCard,
  discardCard,
  endTurn,
  loadGame,
  playStop,
  takeDamage,
  discardWeapon,
  defendBushido,
  hanzoAbility,
  joinGame,
  startGame,
}
