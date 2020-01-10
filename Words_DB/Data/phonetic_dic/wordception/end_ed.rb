require 'pg'
require 'pry'
require 'yaml'


base_grouped = YAML.load_file('wordception.yaml')

@words = PG.connect(dbname: "words_app")

sql = "SELECT * FROM words;"
allwords = @words.exec(sql)

allwords.values.each_with_index do |array, index|
    word = array[1]
    rhyme = array[2]
    phone = array[4].split(" ")

end

ed_words = []

base_grouped.each_key {|k|
    if base_grouped[k].flatten.include?("#{k}ed")
        ed_words << [k, "#{k}ed"]
    end
}

base_grouped.each_key {|k|
    if base_grouped[k].flatten.include?("#{k}s")
        s_words << [k, "#{k}s"]
    end
}

base_grouped.each_key {|k|
    if base_grouped[k].flatten.include?("#{k}s")
        ing_words << [k, "#{k}ing"]
    end
}

print ed_words
