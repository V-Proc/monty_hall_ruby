require "rspec"
require_relative("../montyhall")

RSpec.describe Player do
  it "Check for correct work of Player" do
    player = Player.new(2)
    expect(player.choosed).to eq(2)
    player.change_or_not(0, true)
    expect(player.choosed).to eq(0)
    expect(player.changed).to eq(true)
    player.change_or_not(2, false)
    expect(player.choosed).to eq(0)
    expect(player.changed).to eq(false)
    expect(player.win).to eq(false)
  end
end

RSpec.describe Monty do
  it "Check for correct work of Monty" do
    hall = Monty.new(1)
    expect(hall.suggest_door(2)).to eq(1)
    expect(hall.suggest_door(1)).not_to eq(1)
  end
end

RSpec.describe Scene do
  it "Check for correct work of Scene" do
    scene = Scene.new(0)
    expect(scene.open_choosed(2)).to eq(false)
    expect(scene.open_choosed(1)).to eq(false)
    expect(scene.open_choosed(0)).to eq(true)
  end
end

RSpec.describe SimulationMode do
  #helper class to stub random
  class StubRand
    def initialize()
      @innerstate = 0
    end
    
    def val()
      if(@innerstate == 0) then
        @innerstate = 2
        return 0
      else
        @innerstate = 0
        return 2
      end
    end
  end
  it "Check for correct stat result" do
    coin = StubRand.new()
    def flip_coin() return coin.val() end
    allow(Object).to receive(:rand).and_invoke(->{:flip_coin})
    simulation = SimulationMode.new(100)
    expect(simulation.stats["change"]["winrate"]).to be > (simulation.stats["no_change"]["winrate"])
    $stderr.puts(simulation.stats)
  end
end

RSpec.describe InteractiveMode do
  interaction = nil
  it "Check for correct work of method checked_door_choose" do
    allow_any_instance_of(Object).to receive(:gets).and_return("1")
    allow_any_instance_of(Object).to receive(:rand).and_return(1)
    interaction = InteractiveMode.new()
    interaction.checked_door_choose()
    test_player = interaction.instance_variable_get(:@player)
    expect(test_player.choosed).to eq(1)
  end

  it "Check for correct work of method checked_change_option" do
    allow_any_instance_of(Object).to receive(:gets).and_return("y")
    allow_any_instance_of(Object).to receive(:rand).and_return(2)
    interaction.checked_change_option()
    test_player = interaction.instance_variable_get(:@player)
    expect(test_player.choosed).to eq(2)
    expect(test_player.changed).to eq(true)
  end
  
  it "Check for correct work of method output_result" do
    interaction.output_result
    test_player = interaction.instance_variable_get(:@player)
    expect(test_player.win).to eq(false)
  end
end
