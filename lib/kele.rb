require 'httparty'
require 'json'
require 'roadmap'

class Kele
    include HTTParty
    include Roadmap
    
    base_uri 'https://www.bloc.io/api/v1'
    
    def initialize(email, password)
        @email = email
        @current_user = nil
        @my_mentor_id = nil
        response = self.class.post("/sessions", body: { email: @email, password: password })
        
        if response["auth_token"].nil?
            puts "#{response.message}! Invalid Email or Password"
        else
            @auth_token = response["auth_token"]
            puts "Success!"
            puts "Account Id: #{response["user"]["id"]}, Created at: #{response["user"]["created_at"]}"
        end
    end
    
    def get_me
        response = self.class.get('/users/me', headers: {"authorization" => @auth_token })
        
        @current_user = JSON.parse(response.body)
        puts "Name: #{@current_user["first_name"]} #{@current_user["last_name"]}\nBiography: #{@current_user["bio"]}"
        puts "My Mentor Id: #{@current_user["current_enrollment"]["mentor_id"]}"
        @my_mentor_id = @current_user["current_enrollment"]["mentor_id"]
        @current_user
    end
    
    def get_mentor_availability(mentor_id)
        response = self.class.get('/mentors/'+mentor_id.to_s+'/student_availability', headers: {"authorization" => @auth_token })
        
        availability = JSON.parse(response.body)
        availability.each {|a| puts "Week Day: #{a["week_day"]} | From: #{a["starts_at"]} to #{a["ends_at"]} | Status: #{a["booked"] == true ? "Booked" : "Available" }" }
    end
    
    def check_availability(week_num)
        response = self.class.get("/mentors/#{@my_mentor_id}/student_availability", headers: {"authorization" => @auth_token})
        
        availability = JSON.parse(response.body)
        result = []
        availability.each do |a|
            next if a["week_day"] != week_num
            result << a
        end
        puts "#{result}"
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