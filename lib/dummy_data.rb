require 'faker'

module DummyData
  def self.user_input
    cat = Faker::Creature::Cat
    dog = Faker::Creature::Dog
    horse = Faker::Creature::Horse.breed
    random_animal = Faker::Creature::Animal.name.capitalize
    book = Faker::Book
    television = {
      cop: Faker::TvShows::BrooklynNineNine.character,
      animated: Faker::TvShows::Simpsons.character,
      ed: Faker::TvShows::Community.characters
    }
    jargon = Faker::Company.bs
    lorem = Faker::Lorem.paragraph
    uni = Faker::University.name
    food = Faker::Food.dish
    quote = Faker::GreekPhilosophers.quote
    person = Faker::Name.unique.name
    web = Faker::Internet

    {
      cat_name: cat.name,
      cat_breed: cat.breed,
      dog_name: dog.name,
      dog_breed: dog.breed,
      horse: horse,
      animal: random_animal,
      food: food,
      jargon: jargon,
      book_title: book.title,
      book_genre: book.genre,
      cop_comedy: television[:cop],
      animation: television[:animated],
      college: television[:ed],
      person_name: person,
      email: web.email,
      bio: lorem,
      password: web.password,
      uni: uni,
      description: quote
    }
  end
end
