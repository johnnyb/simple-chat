#!/usr/bin/env ruby

require "httparty"
require "json"

CHAT_URL = "https://api.openai.com/v1/chat/completions"
headers = {
	"Authorization" => "Bearer #{ENV['OPENAI_API_KEY']}",
	"Content-Type" => "application/json"
}

# Models - gpt-4, gpt-3.5-turbo
# gpt-4-1106-preview (GPT-4 Turbo)

structure = {
	:model => "gpt-4",
}
system_message = "You are a helpful assistan."

messages = [
	{
		:role => :system,
		:content => system_message
	}
]

promptcount = 1
print "#{promptcount}) "

ARGF.each_line do |line|
	# Perform the request
	messages.push(:role => :user, :content => line)
	req = structure.merge(:messages => messages)
	resp = HTTParty.post(CHAT_URL, :body => req.to_json, :headers => headers)
	result = JSON.parse(resp.body)

	# Show the user the results
	result["choices"].each do |choice|
		puts "* #{choice["message"]["content"]}"
	end
	puts "** #{result["usage"]["prompt_tokens"]} / #{result["usage"]["completion_tokens"]} / #{result["usage"]["total_tokens"]}"

	# Put this on the chat list
	messages.push(result["choices"][0]["message"])

	promptcount += 1
	print "#{promptcount}) "
end

