require 'pg'
require 'pry'
require 'yaml'

# \S+\s\S+\s\S+$  regex for finding 3 end phones

base_grouped = YAML.load_file('wordception.yaml')
flat = base_grouped.values.flatten
no_match = []

@words = PG.connect(dbname: "words_app")

sql = "SELECT * FROM words;"
allwords = @words.exec(sql)

count= 0

allwords.values.each_with_index do |array, index|
    word = array[1]
    rhyme = array[2]
    phone = array[4].split(" ")


    if flat.include?(word)
        count +=1
    else
        no_match << word
    end


end
