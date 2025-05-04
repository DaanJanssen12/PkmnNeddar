#===============================================================================
# Automatic Level Scaling Event Handlers
# By Benitex
#===============================================================================

# Activates script when a wild pokemon is created
EventHandlers.add(:on_wild_pokemon_created, :automatic_level_scaling,
  proc { |pokemon|
    id = pbGet(LevelScalingSettings::WILD_VARIABLE)
    if id != 0
      AutomaticLevelScaling.setDifficulty(id)
      AutomaticLevelScaling.setNewLevel(pokemon, -1, 42)
    end
  }
)

# Activates script when a trainer pokemon is created
EventHandlers.add(:on_trainer_load, :automatic_level_scaling,
  proc { |trainer|
    id = pbGet(LevelScalingSettings::TRAINER_VARIABLE)
    if trainer && id != 0
      AutomaticLevelScaling.setDifficulty(id)
      average_level = trainer.party.sum(&:level) / trainer.party.length

      trainerPartyAmount = trainer.party.length
      playerPartyAmount = $player.party.length
      if (trainerPartyAmount - playerPartyAmount) > 3
        average_level -= 3
      elsif trainerPartyAmount > playerPartyAmount
        average_level -= (trainerPartyAmount - playerPartyAmount)
      end

      for pokemon in trainer.party
		  custom_moves = nil
		  if has_custom_moves?(pokemon)
			custom_moves = pokemon.moves.map { |m| m&.id }
		  end

		  AutomaticLevelScaling.setNewLevel(pokemon, pokemon.level - average_level, 100)

		  if custom_moves
  # Start with a list of the Pokémon's current moves (if any)
  moves = []

  # Add custom moves first
  custom_moves.each_with_index do |move_id, i|
    if move_id
      move = GameData::Move.get(move_id)  # Get the move data
      if move
        moves[i] = Pokemon::Move.new(move.id)  # Assign the move correctly
      else
        # Handle invalid move ID
        puts "Warning: Invalid move ID '#{move_id}' for #{pokemon.name}."
      end
    end
  end

  # Now, fill in the remaining moves with level-up moves
  species = GameData::Species.get(pokemon.species)  # Get the species data
  level_up_moves = species.moves

  level_up_moves.each do |level, move_id|  # Destructure the pair
	  # Only add the move if it's not already in the list and there's space
	  next if moves.any? { |m| m.id == move_id }  # Skip if the move is already in the list

	  move = GameData::Move.get(move_id)
	  if move
		moves << Pokemon::Move.new(move.id)  # Add valid move
	  end

	  break if moves.size == 4  # Stop if we have 4 moves
	end

  # If there are still empty slots, add more level-up moves (or fallback)
  while moves.size < 4 && !level_up_moves.empty?
    next_move_id = level_up_moves.shift
    next_move = GameData::Move.get(next_move_id)
    moves << Pokemon::Move.new(next_move.id) if next_move
  end

  # Ensure exactly 4 moves (some may be nil, so we need to prune those)
  pokemon.moves = moves.first(4)  # Keep only the first 4 moves
end




		end

    end
  }
)

# Updates partner's pokemon levels after battle
EventHandlers.add(:on_end_battle, :update_partner_levels,
  proc { |_decision, _canLose|
    if $PokemonGlobal.partner != nil
      avarage_level = 0
      $PokemonGlobal.partner[3].each { |pokemon| avarage_level += pokemon.level }
      avarage_level /= $PokemonGlobal.partner[3].length

      for pokemon in $PokemonGlobal.partner[3] do
        AutomaticLevelScaling.setNewLevel(pokemon, pokemon.level - avarage_level, 100)
      end
    end
  }
)

def has_custom_moves?(pokemon)
  species_data = GameData::Species.get(pokemon.species)
  move_list = species_data.moves

  # Only consider moves up to current level
  expected_moves = []
  move_list.each do |level, move_id|
    next if level > pokemon.level
    expected_moves << move_id
  end
  expected_moves.uniq!

  current_moves = pokemon.moves.compact.map(&:id)

  # Check for any unexpected move
  (current_moves - expected_moves).any?
end





