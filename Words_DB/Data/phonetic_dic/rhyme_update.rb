require 'pg'
require 'pry'

@words = PG.connect(dbname: "words_app")

sql = "SELECT * FROM words WHERE phones != '';"
allwords = @words.exec(sql)

sql = "SELECT * FROM words WHERE rhyme = 18;"
rhymes = (@words.exec(sql)).count
all = allwords.count
added = []

print allwords.values[0][4].split(" ")[-3]
puts " "
print rhymes
puts " "
print all
puts " "
allwords.values.each do |array|
    word = array[1]
    rhyme = array[2]
    phone = array[4].split(" ")
    group = 18
    if rhyme != 18 && rhyme != '18'
     if phone[-1] == "EH1"

        added << [word, phone]
        print [word, phone]
        puts " "
        # sql = "UPDATE words SET rhyme = $1 WHERE word = $2"
        # @words.exec_params(sql, [group, word])  
     end
     if (phone[-2] == "EH1")    #&& (((phone[-1] == "CH")) || ((phone[-1] == "Z")) || ((phone[-1] == "K")) || ((phone[-1] == "S")) || ((phone[-1] == "SH")) || ((phone[-1] == "JH")) || ((phone[-1] == "TH")) || ((phone[-1] == "N")) || ((phone[-1] == "T")))
        added << [word, phone]
        print [word, phone]
        puts " "
        # sql = "UPDATE words SET rhyme = $1 WHERE word = $2"
        # @words.exec_params(sql, [group, word])  
     end
    #  if phone[-3] == "IY1" && (((phone[-1] == "D")) || ((phone[-1] == "Z")) || ((phone[-1] == "K")))

    #     added << [word, phone]
    #     print [word, phone]
    #     puts " "
    #  end
     
 
    end

end

puts added.count