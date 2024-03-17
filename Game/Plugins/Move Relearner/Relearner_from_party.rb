module Settings
  EGGMOVESSWITCH  = 59
  MOVERELEARNERSWITCH  = 60
end
RELEARNABLEEGGMOVES = false

class Pokemon
  alias old_can_relearn_move? can_relearn_move? unless method_defined?(:old_can_relearn_move?)
  def can_relearn_move?
    return old_can_relearn_move? && get_relearnable_moves(self).size > 0
  end
end

MenuHandlers.add(:party_menu, :relearner, {
  "name"      => _INTL("Move Relearner"),
  "order"     => 40,
  "effect"    => proc { |screen, party, party_idx|
    pkmn = party[party_idx]
    if !$game_switches[Settings::MOVERELEARNERSWITCH]
      pbMessage(_INTL("You haven't unlocked the Move Relearner yet."))
    elsif pkmn.egg?
      pbMessage(_INTL("You can't use the Move Relearner on an egg."))
    else
      if !pkmn.can_relearn_move?
        pbMessage(_INTL("This Pokémon has no moves to relearn."))
      else
        pbRelearnMoveScreen(party[party_idx])
      end
	 end
  }
})

class MoveRelearnerScreen
  def pbGetRelearnableMoves(pkmn)
    return get_relearnable_moves(pkmn)
  end
end

def get_relearnable_moves(pkmn)
  return [] if !pkmn || pkmn.egg? || pkmn.shadowPokemon?
  moves = []
  pkmn.getMoveList.each do |m|
    next if m[0] > pkmn.level || pkmn.hasMove?(m[1])
    moves.push(m[1]) if !moves.include?(m[1])
  end
  GameData::Species.get(pkmn.species).get_egg_moves.each do |m|
    next if pkmn.hasMove?(m)
    moves.push(m)
  end
  if $game_switches[Settings::EGGMOVESSWITCH] && pkmn.first_moves || RELEARNABLEEGGMOVES ==true && pkmn.first_moves
    tmoves = []
    pkmn.first_moves.each do |i|
      tmoves.push(i) if !moves.include?(i) && !pkmn.hasMove?(i)
    end
    moves = tmoves + moves   # List first moves before level-up moves
  end
  return moves | []   # remove duplicates
end