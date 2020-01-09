require 'pg'
require 'pry'

@words = PG.connect(dbname: "words_app")

sql = "SELECT * FROM words WHERE phones != '';"
allwords = @words.exec(sql)
phones_hash ={}

allwords.values.each_with_index do |array, index|
    word = array[1]
    rhyme = array[2]
    phone = array[4].split(" ")

    array_end_3 = [phone[-3], phone[-2], phone[-1]]
    array_end_2 =[phone[-2], phone[-1]]
    array_end_1 = phone[-1]

   phone_str_3 = array_end_3.join(" ")
   phone_str_2 = array_end_2.join(" ")


    if phones_hash[phone_str_3]
    phones_hash[phone_str_3] << [word, rhyme]
    else
    phones_hash[phone_str_3] = [[word, rhyme]]
    end

    if phones_hash[phone_str_2]
    phones_hash[phone_str_2] << [word, rhyme]
    else
    phones_hash[phone_str_2] = [[word, rhyme]]
    end

    # if phones_hash[array_end_1]
    # phones_hash[array_end_1] << word
    # else
    # phones_hash[array_end_1] = [word]
    # end

        

end
multiples = {}

phones_hash.each_key{|k|
    if phones_hash[k].count > 1
        multiples[k] = phones_hash[k] 
    end
}

phone_rhyme = {}

multiples.each_key{|k| 
    multiples[k].each {|array|
        word = array[0]
        group = array[1]

        if phone_rhyme[k] 
            phone_rhyme[k] << group
        else
            phone_rhyme[k] = [group]
        end
        
    }
    #  puts "#{k} -- #{multiples[k]}"

    # if phone_rhyme[k].uniq.count > 2
    # puts "#{k} -- #{phone_rhyme[k].uniq}"
    # end

    if multiples[k].count > 2
    #puts "#{k} -- #{multiples[k].count}  ---  #{multiples[k][0][0]} #{multiples[k][1][0]} #{multiples[k][2][0]} "
    end

}
#  puts multiples.keys.count


sql = "SELECT * FROM words WHERE phones != '' AND rhyme != '0'"
rhymewords = @words.exec(sql)

group_key= {}
rhymewords.values.each {|array|
 word = array[1]
 rhyme = array[2]
 split = array[4].split(" ")
 phone = [split[-3], split[-2], split[-1]].join(" ")


    if group_key[rhyme]
        group_key[rhyme] << [phone, word]
    else
        group_key[rhyme] = [[phone, word]]
    end

}

match_hash = {}

multiples.each {|k, v|
    if v.count > 2
        group_key.each {|rhyme, array|
            array.each {|element|
                rhyme_phone = element[0]
                word = element[1]
                if rhyme_phone.include?(k)
                    match_hash[k] = [multiples[k][0], rhyme, word]
                end

            }
        }
    end
}
count = match_hash.keys.count
current = 0
random = match_hash.keys.shuffle
random.each {|k|

if match_hash[k][0][1] != match_hash[k][1] && multiples[k].count > 20 #delete last part for all phones not just 3
current += 1
puts " "
puts " "
puts " "
print "#{multiples[k]}"
puts " "
puts " "
puts " "
puts "#{k}  --- #{multiples[k].count} ---  #{match_hash[k]} "
puts " "
puts "#{current} of #{count}"
puts " "
puts " "
puts " "
puts " "
puts "next?"
user_response = gets.chomp

if user_response == 'n'
    break
end

if user_response == 'add'
    multiples[k].each{|array|
    word = array[0]
    rhyme_change = match_hash[k][1]  
    puts "change #{word} to -- #{rhyme_change}"
    sql = "UPDATE words SET rhyme = $1 WHERE word = $2"
    @words.exec_params(sql, [rhyme_change, word]) 


}

end

if user_response == 'change'
    numbers = Array(0..30).map{|v| v.to_s}
    change_response = gets.chomp

    if numbers.include?(change_response)
        multiples[k].each{|array|
        word = array[0]
        rhyme_change = change_response 

        puts "change #{word} to -- #{rhyme_change}"
        sql = "UPDATE words SET rhyme = $1 WHERE word = $2"
        @words.exec_params(sql, [rhyme_change, word]) 
    }
    else
        puts "Did Not Change"
    end
end

end
}
