#eight queens puzzle by genetic algorithm - not very good idea

require 'genetic'

class QueensAlgorithm < Genetic
  def initialize(queens_number)
    super(QueensPool.new(queens_number), 40, 0, 100, 10)
  end

  def arrange
    run(10)
    p @best_genome
    puts "bad queens count " + @best.to_s
  end
end

class QueensPool < GenePool
  def initialize(queens_number)
    @letters = Array.new
    @coordinates = Array.new

    @number = queens_number
    @number.times do |i|
      @letters[i] = i+1
      @coordinates[i] = i+1
    end
  end
  
  def random_chromosome
    c1 = @coordinates.sort_by{rand}
    l1 = @letters.sort_by{rand}
    
    chromosome = Array.new
    @number.times do |i| 
      chromosome << [l1[i], c1[i]]
    end
    chromosome
    #chromosome format [['a', 1], ['h', 6], ... ]
  end

  # @number minus count of bad arranged queens
  def fitness(chromosome)
    bad_count = 0
    chromosome.each do |c1|
      chromosome.each do |c2|
        if(c1[0] == c2[0] and c1[1] == c2[1] and chromosome.index(c1) != chromosome.rindex(c2))
          return 60
        end

        if(c1[0] == c2[0] and c1[1] != c2[1])
          bad_count +=1
        end

        if(c1[1] == c2[1] and c1[0] != c2[0])
          bad_count +=1
        end

        #diagonal
        if(( (@letters.index(c1[0])-@coordinates.index(c1[1]) == @letters.index(c2[0])-@coordinates.index(c2[1])) or (@letters.index(c1[0])+@coordinates.index(c1[1]) == @coordinates.index(c2[1])+@letters.index(c2[0])) ) and (c1[0] != c2[0]))
          bad_count +=1
        end

      end
    end    
    bad_count
  end

  def crossover(parent1, parent2)    
    result = Array.new 
    p1 = parent1.sort_by{|p| p[0]}
    p2 = parent2.sort_by{|p| p[0]}
    @number.times do |i|
      result[i] = [p1[i], p2[i]].sort_by{rand}[0]
    end
    result
  end

  def mutation(chromosome)
    chromosome = chromosome.sort_by{rand}
    chromosome[0][1], chromosome[1][1], chromosome[2][1] = chromosome[1][1], chromosome[2][1], chromosome[0][1]
    chromosome
  end
end

qa = QueensAlgorithm.new(8)
qa.arrange()
