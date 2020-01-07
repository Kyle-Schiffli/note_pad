require 'pg'
require 'pry'

@words = PG.connect(dbname: "words_app")

# sql = "UPDATE words SET rhyme = $1 WHERE word = $2"
# @words.exec_params(sql, [rhyme_change, word]) 

sql = "SELECT * FROM words;"
allwords = @words.exec(sql)

words_hash = {}
allwords.values.each {|value|
 words_hash[value[1]] = [value[2], value[3], value[4]]
}



loop do
puts "---- Options ----"
puts "Search"
puts "Quit: q"
input = gets.chomp

    if input == "q"
        break
    end

    if input == "search"
        print "Word: "
        serach_word = gets.chomp
        sql = "SELECT * FROM words WHERE word = $1"
        search_result = @words.exec_params(sql, [serach_word]) 
        print search_result.values
    end

    if input == "rhyme"
        print "Word: "
        serach_word = gets.chomp
        sql = "SELECT * FROM words WHERE word = $1"
        search_result = @words.exec_params(sql, [serach_word]) 
        print search_result.values
    end

end
