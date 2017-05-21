# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
# Rails.application.load_seed
require 'image_string'

def faker_title
 pick =[
  [Faker::Beer.name, Faker::TwinPeaks.quote],
  [Faker::Book.title, Faker::TwinPeaks.quote],
  [Faker::Cat.breed, Faker::TwinPeaks.quote],
  ["Chuck Norris", Faker::ChuckNorris.fact]].sample

 return {title: pick.first, message: pick.last}
end


10.times do 
	chat = Chat.new
		# The coordinates of a box drawn inside AZ 
		lat = Random.rand(32.26855544621476..36.98500309285596)
		long = Random.rand(-114.0380859375..-109.05029296875)
		chat.location = [long, lat]
		user_id = ["5856d773c2382f415081e8cd", "585716f4c29163000406ff86", "58574fd110ded40004c956dc"].sample
		chat.user_id = user_id
		fake_stuff = faker_title
		chat.title = fake_stuff[:title]
		# chat.message = fake_stuff[:message]
	chat.save
end

10.times do 
	mess = Message.new
		lat = Random.rand(32.26855544621476..36.98500309285596)
		long = Random.rand(-114.0380859375..-109.05029296875)
		mess.location = [long, lat]
		mess.chat = Chat.all.sample.id
		user_id = ["5856d773c2382f415081e8cd", "585716f4c29163000406ff86", "58574fd110ded40004c956dc"].sample
		mess.user_id = user_id
		mess.timestamp = (1..30).to_a.sample.days.ago
		fake_stuff = faker_title
		mess.text = fake_stuff[:message]
	mess.save
end


mess = Message.new
	lat = Random.rand(32.26855544621476..36.98500309285596)
	long = Random.rand(-114.0380859375..-109.05029296875)
	mess.location = [long, lat]
	mess.chat = Chat.all.sample.id
	user_id = ["5856d773c2382f415081e8cd", "585716f4c29163000406ff86", "58574fd110ded40004c956dc"].sample
	mess.user_id = user_id
	mess.timestamp = (1..30).to_a.sample.days.ago
	fake_stuff = faker_title
	mess.text = fake_stuff[:message]
	mess.content = ImageString.image_file
mess.save






	