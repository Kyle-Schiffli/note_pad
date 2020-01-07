require 'pg'
require 'pry'

@words = PG.connect(dbname: "words_app")
sql = "SELECT * FROM words;"
allwords = @words.exec(sql)

# sql = "UPDATE words SET rhyme = $1 WHERE word = $2"
# @words.exec_params(sql, [rhyme_change, word]) 

sql = "SELECT rhyme FROM words WHERE rhyme != 0;"
all_rhymes = @words.exec(sql).values
rhyme_count = all_rhymes.count
group_count = all_rhymes.uniq.count
count_by_group = {}

all_rhymes.each {|v| 
    if count_by_group.has_key?(v)
        count_by_group[v] += 1
    else
        count_by_group[v] = 1
    end
}


words_hash = {}
allwords.values.each {|value|
 words_hash[value[1]] = [value[2], value[3], value[4]]
}
puts "  "
puts "  "
puts "-----------------------------------------------------------------------------------------------"
puts "  "
puts "Current Status"
puts "Total Words: #{allwords.values.count}"
puts "# of Rhymes: #{rhyme_count}"
puts "# of Rhyme Groups: #{group_count}"
puts " "
puts "-----------------------------------------------------------------------------------------------"



loop do
puts "---- Options ----"
puts "Search: s"
puts "Change"
puts "Stats"
puts "Quit: q"
input = gets.chomp.downcase

    if input == "q"
        break
    end

    if input == "s"
        print "Word: "
        serach_word = gets.chomp
        sql = "SELECT * FROM words WHERE word = $1"
        search_result = @words.exec_params(sql, [serach_word]) 
        word_result = search_result.values[0][1]
        rhyme_result = search_result.values[0][2]
        syl_result = search_result.values[0][3]
        phone_result = search_result.values[0][4]

        puts "Word: #{word_result}   --  Rhyme: #{rhyme_result}  -- Syl: #{syl_result}  -- Phone: #{phone_result}"
        puts " "
    end

    if input == "change"
        print "Word: "
        change_word = gets.chomp

        print "Rhyme: "
        change_rhyme = gets.chomp

        puts "Are you sure?"
        print "Change #{change_word} to #{change_rhyme}? y/n: "
        response = gets.chomp

        if response == 'y'
            sql = "UPDATE words SET rhyme = $1 WHERE word = $2"
            @words.exec_params(sql, [change_rhyme, change_word]) 
        end

    end

    if input == "stats"
        puts "  "
        puts "  "
        puts "-----------------------------------------------------------------------------------------------"
        puts "  "
        puts "Current Status"
        puts "Total Words: #{allwords.values.count}"
        puts "# of Rhymes: #{rhyme_count}"
        puts "# of Rhyme Groups: #{group_count}"
        count_by_group.each_key{|k| puts "Group: #{k}    --    #{count_by_group[k]}"}
        puts " "
        puts "-----------------------------------------------------------------------------------------------"

    end

end
