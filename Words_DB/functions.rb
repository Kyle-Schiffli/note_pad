class Database
  
  @words = PG.connect(dbname: "words_app")
  
  def self.query(sql)
    @words.exec(sql)
  end
  
  def self.execute(sql, input)
    
    @words.exec_params(sql, [input])  
  end
  
  def self.delete(sql)
    @words.exec(sql)
  end
  
  def self.first_entry
    @words.exec("SELECT * FROM words LIMIT 1;").values
  end
  
  #find a word in any table, defaults to main words table
  def self.word_search(word, table = "words")
    
    sql = "SELECT * FROM #{table} WHERE word = $1"
    
    @result = @words.exec_params(sql, [word]).values
      if @result.flatten.empty?
        return false
      else
        @result
      end
  
  end  
  
  def self.add_line(user_id, line, syllables, syllable_count, end_rhyme)
    sql = "INSERT INTO all_lines 
          (user_id, line, syllables, syllable_count, end_rhyme)
          VALUES ($1, $2, $3, $4, $5)"
          
      @words.exec_params(sql, 
      [user_id, line, syllables, syllable_count, end_rhyme])  
        
  end
  
  def self.save_all()
    sql = "UPDATE all_lines SET saved = 'y' WHERE saved = 'n'"
          
    @words.exec(sql)
  end
  
  def self.random_words(number = 1)
    sql = "SELECT * FROM words"
          
    @result = (@words.exec(sql)).column_values(1).sample(number)
    @result

  end

  def self.find_all_rhymes(rhyme_group)
    sql = "SELECT * FROM words WHERE rhyme = $1"
    @result = @words.exec_params(sql, [rhyme_group]).column_values(1)
    
    @result
  end
  
    def self.find_all_syllables(count)
    sql = "SELECT * FROM words WHERE syllable = $1"
    @result = @words.exec_params(sql, [count]).column_values(1)
    
    @result
  end
  
  def self.add_to_modifier(word)
    sql = "INSERT INTO modifier (word)
          VALUES ($1)"
    @words.exec_params(sql, [word])  
  end
  
  def self.delete_modifier(word)
    sql = "DELETE FROM modifier WHERE word = $1"
    @words.exec_params(sql, [word])  
  end
  
  def self.add_word(word, rhyme = 0, syllable = 0)
    sql = "INSERT INTO words (word, rhyme, syllable)
          VALUES ($1, $2, $3)"
    @words.exec_params(sql, [word, rhyme, syllable]) 
  end
  
  def self.modify_word(word, rhyme = 0, syllable = 0)
    sql = "UPDATE words SET rhyme = $1, syllable = $2
          WHERE word = $3"
    @words.exec_params(sql, [rhyme, syllable, word]) 
  end
  
  def self.note_pad_search(word)
    sql = "UPDATE current_session SET word_search = $1 WHERE id = 1"
    @words.exec_params(sql, [word])
  end
  
end

helpers do
#used for notepad
  def analyze(line, hash)
    line_array = line.split(" ")
    result_array = line_array.map do |word|
      lower_case = word.downcase
      if hash[lower_case]
        (hash[lower_case])[0][3]
      else
        "?"
      end
    end
    result_array
  end
  
  #uses result from analyze method
  def syllable_count(result_array)
    array = result_array.map(&:to_i)
    count = 0
    array.each {|element| count += 1 if element == 0}
    array.inject(:+) + count
  end
  
  def analyzer_breakdown_count(input)
    filtered = input.delete(",.!?\":;()")
    array = filtered.split(" ").map {|word| word.downcase}
    hash = {}
    
    array.uniq.each do |word|
      hash[word] = [array.count(word)]
    end
    
    hash
  end

  def analyzer_breakdown_rhyme(hash)
    hash.each {|key, value| 
     result = Database.word_search(key)
    #  hash[key][1] = result[2]
    #  hash[key][2] = result[3]
    }
    return hash
  end
  
  def rhyme_array(rhyme_group)
    result = ' '
    
    if rhyme_group == "0"
      result = "Could not find any rhymes for that word"
      
    else
      array = Database.find_all_rhymes(rhyme_group)
      result = array.sample(20).sort{|a, b| a.length <=> b.length}#.join("\n")
    end
    result
  end
  
  def random_word(number = 1)
    sql = "SELECT rhyme FROM words GROUP BY rhyme ORDER BY rhyme ASC"
    random_group = Database.query(sql).values.flatten.sample
    random_rhyme = Database.find_all_rhymes(random_group).sample(number)
    return random_rhyme
  end
  
  def brain_stormer()
    alphabet = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "y"]
    random_letter = alphabet.shuffle()
    word = random_word()
    num = rand()
    
    if num > 0.5
      return word
    else
      return random_letter[0]
    end
    
    
  end

end