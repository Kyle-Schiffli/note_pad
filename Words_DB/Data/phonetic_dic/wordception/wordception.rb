#group words that have smaller words in them

require 'pg'
require 'pry'
require 'yaml'

# require 'yaml'

# $db_file = 'filename.yaml'

# def load_data
#   text = File.read 'db.yaml'
#   return YAML.load text
# end

# def store_data hash
#   f = File.open($db_file, 'w')
#   f.write hash.to_yaml
#   f.close
# end

file = 'wordception.yaml'

@words = PG.connect(dbname: "words_app")

sql = "SELECT * FROM words;"
allwords = @words.exec(sql)

grouped = {}
count = 0

allwords.values.each_with_index do |array, index|
    word = array[1]
    word_size = word.length
    rhyme = array[2]
    phone = array[4]

    allwords.values.each do |array2|
        word_2 = array2[1]
        rhyme_2 = array2[2]
        word_2_size = word_2.length
        phone2 = array2[4]

        if word_2.include?(word) && word_2_size > word_size
            if grouped[word] 
                grouped[word] << [word_2, rhyme_2, phone2]
            else
                grouped[word] = [[word_2, rhyme_2, phone2]]
            end 
        end
    end
    count +=1
    system "clear"
    puts count

end


  f = File.open(file, 'w')
  f.write grouped.to_yaml
  f.close
