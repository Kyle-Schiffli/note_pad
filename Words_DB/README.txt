start on mac

brew services start postgresql

bundle exec ruby words_db.rb

http://localhost:4567/


start on windows






set up local machine - mac

1. Download postgresql - https://www.codementor.io/@engineerapart/getting-started-with-postgresql-on-mac-osx-are8jcopb
2. Download bundle - gem install bundler
3. Bundle install
4. create postgres db -  createdb words_app
5. dump db from git -  psql words_app < words_app.bak

set up local machine - windows
1. Download postgresql - https://www.enterprisedb.com/downloads/postgres-postgresql-downloads
2. Download bundle - gem install bundler
3. Bundle install
4. create postgres db -  createdb words_app
5. dump db from git -  psql words_app < words_app.bak


save db  -  pg_dump words_app > words_app.bak

dropdb words_app