require 'json'
require 'pg'
require 'pry'

@words = PG.connect(dbname: "words_app")

file = File.read('phonetic_array.json')
hash = JSON.parse(file)


sql = "SELECT * FROM words;"
allwords = @words.exec(sql)


allwords.values.each do |array|
    word = array[1]
    if hash.has_key?(word)
        phones = hash[word]
        sql = "UPDATE words SET phones = $1 WHERE word = $2"
        @words.exec_params(sql, [phones, word])  
    end
end

