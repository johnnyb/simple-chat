#!/usr/bin/env ruby

require "httparty"
require "json"
require "optparse"

CHAT_URL = "https://api.openai.com/v1/chat/completions"
headers = {
	"Authorization" => "Bearer #{ENV['OPENAI_API_KEY']}",
	"Content-Type" => "application/json"
}

# Models - gpt-4, gpt-3.5-turbo
# gpt-4-1106-preview (GPT-4 Turbo)

model = "gpt-4"
system_message = "You are a helpful assistant."
logdir = ""
chatnum = rand(10000)

OptionParser.new do |parser|
	parser.on("-m", "--model MODELNAME", "specifies a specific model to use") do |m|
		model = m
	end
	parser.on("-l", "--logidr DIR", "specifies the log directory") do |l|
		logdir = l
	end
	parser.on("-s", "--system MESSAGE", "starts with a system message") do |s|
		system_message = s
	end
end.parse!

structure = {
	:model => model,
}

messages = [
	{
		:role => :system,
		:content => system_message
	}
]

promptcount = 1
puts "Chat ##{chatnum}"
print "#{promptcount}) "


def logreq(logdir, chatnum, promptnum, url, req, resp)
	return if logdir == nil || logdir == ""
	File.open("#{logdir}/chat_#{chatnum}_#{promptnum}.log", "w+") do |fh|
		fh.puts(url)
		fh.puts(req)
		fh.puts(resp)
	end
end



ARGF.each_line do |line|
	# Perform the request
	messages.push(:role => :user, :content => line)
	req = structure.merge(:messages => messages)
	resp = HTTParty.post(CHAT_URL, :body => req.to_json, :headers => headers)
	result = JSON.parse(resp.body)
	logreq(logdir, chatnum, promptcount, CHAT_URL, req, result.to_json)

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

