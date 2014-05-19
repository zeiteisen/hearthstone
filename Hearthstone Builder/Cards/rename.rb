require "rubygems"
require "json"

print "start renaming\n"
jsonFile = open("all-collectibles.json")
json = jsonFile.read

parsed = JSON.parse(json);

counter = 0
parsed["cards"].each do |card|
	print card["name"] + " "
	print card["id"].to_s + "\n"
	file = open(card["id"].to_s + ".jpg")
	File.rename(file, card["name"] + ".jpg")
end

print "renamed " + counter.to_s + " files\n";
