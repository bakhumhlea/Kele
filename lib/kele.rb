require 'httparty'

class Kele
    include HTTParty
    
    base_uri 'https://www.bloc.io/api/v1'
    
    def initialize(email, password)
        @email = email
        
        response = self.class.post("/sessions", body: { email: @email, password: password })
        
        if response["auth_token"].nil?
            puts "Invalid Input!"
        else
            @auth_token = response["auth_token"]
            puts "Success!"
            puts "Account Id: #{response["user"]["id"]}, Created at: #{response["user"]["created_at"]}"
        end
    end
    
    def self.greet(lang='en')
        hi = ''
        case lang
            when 'en'
                hi = 'Hello'
            when 'jp'
                hi = 'こんにちは'
            when 'es'
                hi = 'Hola'
            when 'de'
                hi = 'Hallo'
            when 'fr'
                hi = 'Bonjour'
            when 'th'
                hi = 'สวัสดี'
            else
                puts "I assume you speak English."
                hi = 'Hello'
        end
        puts "#{hi}!"
    end
end