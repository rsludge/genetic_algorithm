class Genetic
  attr_accessor :population
  attr_reader :best

  def initialize(gene_pool, population_size, elitism=0, old_survival=100, mutation_probability=10)
    # set parameters
    @gene_pool = gene_pool
    @elitism = elitism
    @old_survival = old_survival
    @pop_size = population_size
    @mutation_probability = mutation_probability
  end

  #generate first population
  def first_population
    generation = []
    @pop_size.times do
      generation << @gene_pool.random_chromosome
    end
    @population = generation.sort_by{|ch| fitness(ch)}
    @best = fitness(@population[0])
    @best_genome = Array.new
    @population[0].each do |p|
      @best_genome << p.clone
    end
  end

  def fitness(chromosome)
    # fitness function provides by gene_pool object
    @gene_pool.fitness(chromosome)
  end

  def choose_best
    #if best in new population better then old best, change
    if(fitness(@population[0]) < @best)
      @best = fitness(@population[0])
      @best_genome = Array.new
      @population[0].each do |p|
        @best_genome << p.clone
      end
    end
  end

  def step
    reproduction
    mutate
    @population = selection.sort_by{|ch| fitness(ch)}
    choose_best
  end 

  def mutate
    mutate_size = @pop_size * @mutation_probability/100
    mutate_size.times do
      i = rand @pop_size
      @population[i] = @gene_pool.mutation(Array.new(@population[i]))
    end
  end

  def randomized_selected
    # randomly select genome from population considering order
    rand(@population.size)/(rand(@population.size*0.03)+1)
  end

  def reproduction
    #create a new generation and combine it with the previous
    new_generation=[]
    @population.size.times do
      new_generation << @gene_pool.crossover(Array.new(@population[randomized_selected]), Array.new(@population[randomized_selected]))
    end
    #new population consists of old and new generation survivors
    @population = (selection(@pop_size*@old_survival/100) + new_generation).sort_by{|ch| fitness(ch)}
    @population.slice!(@pop_size, @population.count-@pop_size)
  end

  def selection(size=@pop_size)    
    survivors = []   
    elit_size = size * @elitism/100
    survivors[0..elit_size-1] = @population[0..elit_size-1]
    (size - elit_size).times do
      survivors << @population.delete_at(randomized_selected)
    end
    survivors.slice(@pop_size, survivors.count-@pop_size)
  end

  def run(steps)
    #main function
    first_population
    steps.times do |i|
      step
      puts "--Step " + (i+1).to_s + "--"
    end
  end

  def run_debug(steps)
    #main function
    first_population

    puts "First population:"   
    print_population_info
    steps.times do |i|
      step
      puts "Step " + (i+1).to_s + ":"
      print_population_info
    end
  end

  def print_population_info
    sum = (@population).inject(0) do |s, x|
      s += fitness(x)
    end
    puts "Average fittness:" + (sum/@pop_size).to_s
    puts "Three best:\n" + fitness(@population[0]).to_s + "\n" + fitness(@population[1]).to_s + "\n" + fitness(@population[2]).to_s + "\n"
    puts "The best of all steps:" + best.to_s
    puts "Population:"
    @population.each do |x|
      puts fitness(x)
    end
  end
end

class GenePool
  # abstract methods
  def crossover(parent1, parent2)
    raise "Abstract method called"
  end
  def random_chromosome
    raise "Abstract method called"
  end
  def fitness(chromosome)
    raise "Abstract method called"
  end

  # onepoint crossover, change part in the beginning
  # must be overriden, if genetic algithm is not binary
  def onepoint_crossover(parent1, parent2, percent)
    point = parent1.size * percent/100.0
    parent1[0..point] = parent2[0..point]
    parent1
  end

  # twopoint crossover, change part in the middle
  # must be overriden, if genetic algithm is not binary
  def twopoint_crossover(parent1, parent2, percent1, percent2)
    point1 = parent1.size * percent1/100.0
    point2 = parent1.size - parent1.size * percent2/100.0
    parent1[point1..point2] = parent2[point1..point2]
    parent1
  end

  # must be overriden, if genetic algithm is not binary
  def mutation(chromosome)
    # change one of the genoms randomly
    mutate_index = rand(chromosome.size)
    chromosome[mutate_index] = (1..chromosome[mutate_index].size).inject("") do |new_gene, i|
      new_gene << rand(2).to_s
    end 
    chromosome
  end
end
