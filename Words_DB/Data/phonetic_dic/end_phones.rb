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

multiples.each_key{|k| 
# if multiples[k].count > 100
    puts "#{k} -- #{multiples[k]}"
# end
}

# puts multiples.keys.count