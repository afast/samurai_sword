import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import Card from './Card'

const Deck = props => (
  <div className="deck">
    <span className="remaining">{props.size} cards</span>
    <Card />
  </div>
)

Deck.defaultProps = {
  size: 0
}

Deck.propTypes = {
  size: PropTypes.number
}

export default Deck
