class Player
  attr_accessor :choosed, :changed, :win
  
  def initialize(door_num)
    @choosed = door_num
    @win = false
  end

  def change_or_not(suggested_door, change)
    @changed = change
    if (@changed) then @choosed = suggested_door end
  end
end

class Monty
  attr_accessor :suggested_door
  def initialize(win)
    @win_door = win
  end

  def suggest_door(choosed_door)
    @suggested_door = rand(3)
    if(@win_door == choosed_door) then
      while(true)
      (@suggested_door != choosed_door) ? (return @suggested_door) : (@suggested_door = rand(3))
      end
    else
      @suggested_door = @win_door
      return @suggested_door
    end        
  end
  
end

class Scene
 
  def initialize(win_door)
    @doors = [false, false, false]
    @doors[win_door] = true
  end

  def open_choosed(choosed_door)
    @doors[choosed_door]
  end
end

class SimulationMode
  def initialize(times_count)
    #needed data: player choose(0), monty suggest(1), doors count(2), winner door(3), player win(4)
    @runs_nc = Array.new(times_count) {Array.new(5)} #nc stands for No Change decision about choosed door
    @runs_c = Array.new(times_count) {Array.new(5)} #c snands for change decision
    @stats = {"no_change" => {"total" => times_count, "win" => 0, "fail" => 0, "winrate" => 0.0 },
              "change" => {"total" => times_count, "win" => 0, "fail" => 0, "winrate" => 0.0}}
    self.changed(times_count)
    self.not_changed(times_count)
    self.calc_stats(times_count)
  end

  def not_changed(times_count)
    counter = 0
    while(counter < times_count) do
      win_door = rand(3)
      choosed_door = rand(3)
      player = Player.new(choosed_door)
      hall = Monty.new(win_door)
      scene = Scene.new(win_door)
      
      suggested_door = hall.suggest_door(choosed_door)
      player.change_or_not(suggested_door, false)
      win = scene.open_choosed(player.choosed)

      @runs_nc[counter][0] = choosed_door
      @runs_nc[counter][1] = suggested_door
      @runs_nc[counter][2] = 3
      @runs_nc[counter][3] = win_door
      @runs_nc[counter][4] = win
      
      if(@runs_nc[counter][4]) then @stats["no_change"]["win"]+=1
      else @stats["no_change"]["fail"]+=1 end
      
      counter+=1
    end
  end

  def changed(times_count)
    counter = 0
    while(counter < times_count)
      win_door = rand(3)
      choosed_door = rand(3)
      player = Player.new(choosed_door)
      hall = Monty.new(win_door)
      scene = Scene.new(win_door)
      
      suggested_door = hall.suggest_door(choosed_door)
      player.change_or_not(suggested_door, true)
      win = scene.open_choosed(player.choosed)

      @runs_c[counter][0] = choosed_door
      @runs_c[counter][1] = suggested_door
      @runs_c[counter][2] = 3
      @runs_c[counter][3] = win_door
      @runs_c[counter][4] = win

      
      if(@runs_c[counter][4]) then @stats["change"]["win"]+=1
      else @stats["change"]["fail"]+=1 end
      
      counter+=1
    end
  end

  def calc_stats(times_count)      
      @stats["no_change"]["total"] = times_count
      @stats["no_change"]["winrate"] = 100.0 * @stats["no_change"]["win"]/@stats["no_change"]["total"]
      
      
      @stats["change"]["total"] = times_count
      @stats["change"]["winrate"] = 100.0 * @stats["change"]["win"]/@stats["change"]["total"]      
  end

  def stats()
    @stats
  end  
end

class InteractiveMode
  
  def checked_door_choose()
    temp = 0
    begin
      puts "Choose door 0, 1 or 2"
      temp = Integer(gets, 10)
      if(temp > 2) then raise StandardError end
    rescue => e
      puts "Incorrect input, try again"
      retry
    end
    @player = Player.new(temp)
  end
  
  def checked_change_option()
    suggestion = @hall.suggest_door(@player.choosed)
    begin
      puts "You have been suggested to switch door to number #{suggestion} change or not?(y/n)"
      temp = gets.chomp
      if(temp == "y")
        @player.change_or_not(suggestion, true)
      elsif(temp == "n")
        @player.change_or_not(suggestion, false)
      else        
        raise StandardError
      end
    rescue => e
      puts(temp == "y")
      puts("temp=#{temp}")
      retry
    end
  end
  
  def output_result()
    @player.win= @scene.open_choosed(@player.choosed)
    if(@player.win) then
      puts "You win, choosed door number: #{@player.choosed} \n"      
      puts "Monty Hall suggest door number #{@hall.suggested_door}."
      @player.changed ? puts("You accepted") : puts("You rejected")
    else
      puts "You loose, choosed door number: #{@player.choosed} \n"      
      puts "Monty Hall suggest door number #{@hall.suggested_door}."
      @player.changed ? puts("You accepted") : puts("You rejected")
    end
  end
  
  def run()
    self.checked_door_choose()
    self.checked_change_option()
    self.output_result()
  end
  
  def initialize()
    @win_door = rand(3)
    @hall = Monty.new(@win_door)
    @scene = Scene.new(@win_door)
  end
end

#in case of needence for interactive use of this code just run shell() 
def shell()
  while(true)
  puts "s - run simulation and print result"
  puts "i - run interactive mode"
  puts "q - quit"
  key = gets
  case key.chomp
  when "s"
    sim = SimulationMode.new(1000000)
    puts sim.stats
  when "i"
    inter = InteractiveMode.new()
    inter.run()
  when "q"
    break
  else
    puts "Enter valid key"
  end
end
end
