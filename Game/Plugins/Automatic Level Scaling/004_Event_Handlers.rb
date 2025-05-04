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
      avarage_level = 0
      trainer.party.each { |pokemon| avarage_level += pokemon.level }
      avarage_level /= trainer.party.length
	  
	  trainerPartyAmount = trainer.party.length
	  playerPartyAmount = $player.party.length
	  if (trainerPartyAmount - playerPartyAmount) > 3
		avarage_level -= 3
	  elsif trainerPartyAmount > playerPartyAmount
		avarage_level -= (trainerPartyAmount - playerPartyAmount)
	  end

      for pokemon in trainer.party do
        AutomaticLevelScaling.setNewLevel(pokemon, pokemon.level - avarage_level, 100)
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
