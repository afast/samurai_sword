
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

export const playCard = (id, player, card, target, geisha, accepted) => {
  return makeAuthenticatedRequest(`${API_URL}/games/${id}/play_card.json`, { method: 'POST', body: JSON.stringify({
    player: player.character,
    card: card.name,
    target: target,
    geisha: geisha,
    accepted: accepted,
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

export const proposeForIntuicion = (id, character, card_name) => {
  return makeAuthenticatedRequest(`${API_URL}/games/${id}/propose_for_intuicion.json`, { method: 'POST', body: JSON.stringify({
    character: character,
    card_name: card_name
  }) })
}

export const stealByIntuicion = (id, character, card_name) => {
  return makeAuthenticatedRequest(`${API_URL}/games/${id}/steal_by_intuicion.json`, { method: 'POST', body: JSON.stringify({
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

export const kanbeiAbility = (id, character, card_name) => {
  return makeAuthenticatedRequest(`${API_URL}/games/${id}/kanbei_ability.json`, { method: 'POST', body: JSON.stringify({
    character: character,
    card_name: card_name
  }) })
}

export const okuniAbility = (id, character, card_name) => {
  return makeAuthenticatedRequest(`${API_URL}/games/${id}/okuni_ability.json`, { method: 'POST', body: JSON.stringify({
    character: character,
    card_name: card_name
  }) })
}

export const shimaAbility = (id, character, card_name) => {
  return makeAuthenticatedRequest(`${API_URL}/games/${id}/shima_ability.json`, { method: 'POST', body: JSON.stringify({
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

export const takeDamage = (id, character, campesinos) => {
  return makeAuthenticatedRequest(`${API_URL}/games/${id}/take_damage.json`, { method: 'POST', body: JSON.stringify({
    character,
    campesinos,
  }) })
}

export const playStop = (id, character) => {
  return makeAuthenticatedRequest(`${API_URL}/games/${id}/play_stop.json`, { method: 'POST', body: JSON.stringify({
    character,
  }) })
}

export const koteSelectedPlayer = (id, character) => {
  return makeAuthenticatedRequest(`${API_URL}/games/${id}/kote_selected_player.json`, { method: 'POST', body: JSON.stringify({
    character,
  }) })
}

export const playCounterStop = (id, character) => {
  return makeAuthenticatedRequest(`${API_URL}/games/${id}/play_counter_stop.json`, { method: 'POST', body: JSON.stringify({
    character,
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
  playCounterStop,
  takeDamage,
  discardWeapon,
  defendBushido,
  hanzoAbility,
  kanbeiAbility,
  okuniAbility,
  shimaAbility,
  proposeForIntuicion,
  stealByIntuicion,
  joinGame,
  startGame,
  koteSelectedPlayer,
}
