require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"
require "pg"
require 'yaml'
require 'pry'
require_relative 'functions'


configure do
  enable :reloader
  also_reload "/stylesheets/note.css"
end


get "/" do
  
  erb :login
end

post "/login" do
  username = params[:username]
  password = params[:password].to_s
  
  sql = "SELECT password FROM users WHERE username = $1"
  correct = Database.execute(sql, username).values.flatten
  
  if username && password && correct.empty? != true
    
    if password == correct[0]
      
      
      redirect "/home" 
    end
  end
    redirect "/"
end


get "/home" do
  
  @result = Database.word_search("ace")
  
  @result = "Could Not Find That Word" if @result.empty?
    
 erb :home
end


    #    #     #    #    #       #     # ####### ####### ######  
   # #   ##    #   # #   #        #   #       #  #       #     # 
  #   #  # #   #  #   #  #         # #       #   #       #     # 
 #     # #  #  # #     # #          #       #    #####   ######  
 ####### #   # # ####### #          #      #     #       #   #   
 #     # #    ## #     # #          #     #      #       #    #  
 #     # #     # #     # #######    #    ####### ####### #     # 

 ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### 
                                                                 

get "/analyzer" do
  sql = "SELECT input_str FROM analyzer WHERE id = 1"
  @input = Database.query(sql).values[0][0]
  
  @word_array = analyzer_breakdown(@input)
  
  
  
erb :analyzer, layout: :layout
end

post "/analyzer" do
  input = params[:analyzer_input]
  sql = "UPDATE analyzer SET input_str = $1 WHERE id = 1"
  
  Database.execute(sql, input)

  redirect "/analyzer"
end

                                                                                                                          
                                                             
 ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### 
                                                             
                                                             
                                                                                                                   

post "/clear_modify" do
  if params[:clear_modify] == "clear"
    sql = "DELETE FROM modifier WHERE word IS NOT NULL"
    Database.delete(sql)
  end
  
  redirect "/word_search"
end

post "/modify" do
  
  modify_word = params[:word]
  modify_rhyme = params[:rhyme]
  modify_syllable = params[:syllable]
  
  if !Database.word_search(modify_word)
    Database.add_word(modify_word, modify_rhyme, modify_syllable)
    Database.delete_modifier(modify_word)
  else
    Database.modify_word(modify_word, modify_rhyme, modify_syllable)
  end
  
  
  
  redirect "/word_search/#{modify_word}"
end

get "/word_search" do
  
  #display of list to be modified
  sql = "SELECT * FROM modifier"
  @modifier_list = Database.query(sql).values
  @modifier_words = @modifier_list.map do |array|
    array[0]
    end

  erb :word_search, layout: :layout  
end

get "/word_search/:word" do
  @query_word = params[:word]
  @result = Database.word_search(@query_word)
  
  if @result
    @rhyme = @result[0][2]
    @syllable = @result[0][3]
  else
    @rhyme = "N/A"
    @syllable = "N/A"
  end
  
  #display of list to be modified
  sql = "SELECT * FROM modifier"
  @modifier_list = Database.query(sql).values
  @modifier_words = @modifier_list.map do |array|
    array[0]
    end
  
  erb :word_search, layout: :layout  
end

post "/word_search" do
  query_word = params[:word]
  
  redirect "/word_search/#{query_word}"
  
  erb :word_search, layout: :layout  
end


# displays array of line id and line from note_pad_session table
# on start up

  #####  ####### #######    #     # ####### ####### ####### ######     #    ######  
 #     # #          #       ##    # #     #    #    #       #     #   # #   #     # 
 #       #          #       # #   # #     #    #    #       #     #  #   #  #     # 
 #  #### #####      #       #  #  # #     #    #    #####   ######  #     # #     # 
 #     # #          #       #   # # #     #    #    #       #       ####### #     # 
 #     # #          #       #    ## #     #    #    #       #       #     # #     # 
  #####  #######    #       #     # #######    #    ####### #       #     # ######  
                                                                                    
  ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### 

get "/note_pad" do

  sql = "SELECT * FROM all_lines WHERE saved = 'n'"
  @current_session = Database.query(sql).values
  @lines = @current_session.map {|array| [array[0], array[2]] }
  @syllables = @current_session.map {|array| array[4]}
  
  sql = "SELECT * FROM current_session"
  test = Database.query(sql).values
  @monkey_test = test[0][1]
  
  #find matching rhymes
  @last_rhyme = "0"
  @second_last_rhyme = "0"
  @third_last_rhyme = "0"
  @last_rhyme_array = []
  @second_rhyme_array = []
  @third_rhyme_array = []
  @syallable_display_1 = Database.find_all_syllables(1).sample(100).join(" - ")
  @syallable_display_2 = Database.find_all_syllables(2).sample(100).join(" - ")
  @syallable_display_3 = Database.find_all_syllables(3).sample(100).join(" - ")


  @random_word_display_1 = Database.random_words(100).join(" - ")
  @random_word_display_2 = Database.random_words(100).join(" - ")
  @random_word_display_3 = Database.random_words(100).join(" - ")
  
  if @lines.length > 0 
    @last_rhyme = (@current_session[-1][3])
      if @last_rhyme != "0"
        @last_rhyme_array = rhyme_array(@last_rhyme).join(" - ")
      end
  else
    @last_rhyme_array = "n/a"
  end
  
  if @lines.length > 1
    @second_last_rhyme = (@current_session[-2][3])
    if @second_last_rhyme != "0"
       @second_rhyme_array = rhyme_array(@second_last_rhyme).join(" - ")
    end
  else
    @second_rhyme_array = "n/a"
  end
  
    if @lines.length > 2
    @third_last_rhyme = (@current_session[-3][3])
      if @third_last_rhyme != "0"
         @third_rhyme_array = rhyme_array(@third_last_rhyme).join(" - ")
      end
  else
    @third_rhyme_array = "n/a"
  end
  # end find matcing rhymes
  
  @old_lines = ["hey there how are you", "This works?"]
  
  erb :note_pad, layout: :layout  
end

#sumbit will add the line and id to db

 ######  #######  #####  #######    #     # ####### ####### #######         ######     #    ######  
 #     # #     # #     #    #       ##    # #     #    #    #               #     #   # #   #     # 
 #     # #     # #          #       # #   # #     #    #    #               #     #  #   #  #     # 
 ######  #     #  #####     #       #  #  # #     #    #    #####           ######  #     # #     # 
 #       #     #       #    #       #   # # #     #    #    #               #       ####### #     # 
 #       #     # #     #    #       #    ## #     #    #    #               #       #     # #     # 
 #       #######  #####     #       #     # #######    #    #######         #       #     # ######  
                                                                    #######                         

                                                                    
##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### 


post "/note_pad" do
  #checkboxes for delete lines and save lines
  if params[:save_all] == "save"
    Database.save_all()
    redirect "/note_pad"
  end
  
  if params[:delete_lines] == "Delete"
    
    @delete_lines = params[:subject]
    
    @delete_lines.each do |line_id|
      sql = "DELETE FROM all_lines WHERE saved = 'n' AND id = #{line_id}"
    Database.delete(sql)
    end
    redirect "/note_pad"
  end
  #---------word search
  @word_search = params[:word_search]
  
  if @word_search != "" || @word_search != nil
  Database.note_pad_search(@word_search)
  end
  
  #-------------end of word search
  
  
#if clear button is selected, everything is deleted form all_lines where saved is 'n' 
  clear_session = params[:clear_session]
  if clear_session == "clear"
    sql = "DELETE FROM all_lines WHERE saved = 'n'"
    Database.delete(sql)
  else  
  
  #--------- Analyzes new lines
    @line = params[:line]
    
    if @line == "" || @line == nil
      redirect "/note_pad"
    end
    
    #gets array of all uniq words in line
    
    @pre_analyzed = @line.split(" ").uniq

    #querys all uniq words and creates hash used by analyze method
    if @pre_analyzed.length > 0
      @analyzed = {}
      @pre_analyzed.each do |word|
       lower_case = word.downcase
       @analyzed[lower_case] = Database.word_search(lower_case)
      end
    #create syallables array and syllable count using @analyzed hash
      @syllables = analyze(@line, @analyzed).join(" ")
      @syllable_count = syllable_count(analyze(@line, @analyzed))
    
    
      last_word = (@pre_analyzed[-1])
      @end_rhyme = 0
    
      if @analyzed[last_word] 
         @end_rhyme = (@analyzed[last_word][0][2])
      end

      Database.add_line(1, @line, @syllables, @syllable_count, @end_rhyme)
      # ------- end of analyzing
      
      #modifier
  #use @analyzed hash to find all N/A words (values with false)
      @unknowns = []
        @analyzed.each do |word, value|
          @unknowns << word if value == false
       end
      @test = {}
          if @unknowns.length > 0
            @unknowns.each do |unknown_word|
              if !Database.word_search(unknown_word, "modifier")
                Database.add_to_modifier(unknown_word)
              end
            end
          end
    #modifier end
      
      
    else
      redirect "/note_pad"
    end
  end  
  
  redirect "/note_pad"
  
  erb :note_pad, layout: :layout  
end


 #     # ####### ####### #######         ######     #    ######           #####  #     # #     # ####### ####### #       ####### 
 ##    # #     #    #    #               #     #   # #   #     #         #     # #     # #     # #       #       #       #       
 # #   # #     #    #    #               #     #  #   #  #     #         #       #     # #     # #       #       #       #       
 #  #  # #     #    #    #####           ######  #     # #     #          #####  ####### #     # #####   #####   #       #####   
 #   # # #     #    #    #               #       ####### #     #               # #     # #     # #       #       #       #       
 #    ## #     #    #    #               #       #     # #     #         #     # #     # #     # #       #       #       #       
 #     # #######    #    #######         #       #     # ######           #####  #     #  #####  #       #       ####### ####### 
                                 #######                         #######                                                         

##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### 


post "/note_pad/shuffle" do
    redirect "/note_pad"
end

##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### 

get "/all_lines" do
  sql = "SELECT * FROM all_lines WHERE saved = 'y'"
  @current_session = Database.query(sql).values
  

  erb :all_lines, layout: :layout 
end

get "/all_lines/:sort" do
  @sort = params[:sort]
  if @sort == 'new'
    sql = "SELECT * FROM all_lines WHERE saved = 'y' ORDER BY id DESC"
    @current_session = Database.query(sql).values
  else
    sql = "SELECT * FROM all_lines WHERE saved = 'y' ORDER BY #{@sort}"
    @current_session = Database.query(sql).values
  end

  erb :all_lines, layout: :layout 
end

##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### 

get "/brain_storm" do
  
  @random_value = brain_stormer()
  
  sql = "SELECT * FROM all_lines WHERE saved = 'n'"
  @current_session = Database.query(sql).values
  @lines = @current_session.map {|array| [array[0], array[2]] }
  @syllables = @current_session.map {|array| array[4]}
  
  #find matching rhymes
  @last_rhyme = "0"
  @second_last_rhyme = "0"
  @last_rhyme_array = []
  @second_rhyme_array = []
  
  if @lines.length > 0 
    @last_rhyme = (@current_session[-1][3])
    @last_rhyme_array = rhyme_array(@last_rhyme)
  else
    @last_rhyme_array = "Could not find any rhymes for that word"
  end
  
  if @lines.length > 1
    @second_last_rhyme = (@current_session[-2][3])
   @second_rhyme_array = rhyme_array(@second_last_rhyme)
  else
    @second_rhyme_array = "Could not find any rhymes for that word"
  end
  # end find matcing rhymes
  
  #start of word scramble
  sql = "SELECT * FROM all_lines WHERE saved = 'y'"
  current_session = Database.query(sql).values
  lines = current_session.map{|line| line[2].split(" ")}
  @fronts = []
  @backs = []
  lines.each do |line|
    random_mid = 0
    random_mid = Array(0..(line.size - 2)).shuffle[0] if line.size > 2
  
    @fronts.push(line.slice!(0..random_mid))
    @backs.push(line)
  end
  
    @fronts = @fronts.shuffle.map{|line| line.flatten.join(" ")}
    @backs = @backs.shuffle.map{|line| line.flatten.join(" ")}
    
    @shuffled = @fronts.zip(@backs).map{|line| line.join(" ")}
  
 
  
  erb :brain_storm, layout: :layout  
end
##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### 

#sumbit will add the line and id to db

post "/brain_storm" do
  
  #checkboxes for delete lines and save lines
  if params[:save_all] == "save"
    Database.save_all()
    redirect "/brain_storm"
  end
  
  if params[:delete_lines] == "Delete"
    
    @delete_lines = params[:subject]
    
    @delete_lines.each do |line_id|
      sql = "DELETE FROM all_lines WHERE saved = 'n' AND id = #{line_id}"
    Database.delete(sql)
    end
    redirect "/brain_storm"
  end
  
  
#if clear button is selected, everything is deleted form all_lines where saved is 'n' 
  clear_session = params[:clear_session]
  if clear_session == "clear"
    sql = "DELETE FROM all_lines WHERE saved = 'n'"
    Database.delete(sql)
  else  
  
  
    @line = params[:line]
    
    #gets array of all uniq words in line
    
    @pre_analyzed = @line.split(" ").uniq

    #querys all uniq words and creates hash used by analyze method
    if @pre_analyzed.length > 0
      @analyzed = {}
      @pre_analyzed.each do |word|
       lower_case = word.downcase
       @analyzed[lower_case] = Database.word_search(lower_case)
      end
    #create syallables array and syllable count using @analyzed hash
      @syllables = analyze(@line, @analyzed).join(" ")
      @syllable_count = syllable_count(analyze(@line, @analyzed))
    
    
      last_word = (@pre_analyzed[-1])
      @end_rhyme = 0
    
      if @analyzed[last_word] 
         @end_rhyme = (@analyzed[last_word][0][2])
      end

      Database.add_line(1, @line, @syllables, @syllable_count, @end_rhyme)
      
      
      #modifier
  #use @analyzed hash to find all N/A words (values with false)
      @unknowns = []
        @analyzed.each do |word, value|
          @unknowns << word if value == false
       end
      @test = {}
          if @unknowns.length > 0
            @unknowns.each do |unknown_word|
              if !Database.word_search(unknown_word, "modifier")
                Database.add_to_modifier(unknown_word)
              end
            end
          end
    #modifier end
      
      
    else
      redirect "/brain_storm"
    end
  end  
  
  redirect "/brain_storm"
  
  erb :brain_storm, layout: :layout  
end


post "/brain_storm/shuffle" do
    redirect "/brain_storm"
end

##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### 

get "/random_words" do
  
  @random_rhyme = random_word()
  
  
  erb :random_words, layout: :layout 
end

##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### 
get "/word_scramble" do
  sql = "SELECT * FROM all_lines WHERE saved = 'y'"
  @current_session = Database.query(sql).values
  lines = @current_session.map{|line| line[2].split(" ")}
  @fronts = []
  @backs = []
  lines.each do |line|
    random_mid = 0
    random_mid = Array(0..(line.size - 2)).shuffle[0] if line.size > 2
  
    @fronts.push(line.slice!(0..random_mid))
    @backs.push(line)
  end
  
    @fronts = @fronts.shuffle.map{|line| line.flatten.join(" ")}
    @backs = @backs.shuffle.map{|line| line.flatten.join(" ")}
    
    @shuffled = @fronts.zip(@backs).map{|line| line.join(" ")}
  erb :word_scramble, layout: :layout 
end

