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
    
    def get_message(page=nil)
        if page.nil?
            response = self.class.get("/message_threads", headers: { "authorization" => @auth_token})
        else
            response = self.class.get("/message_threads", headers: { "authorization" => @auth_token}, body: { "page":page })
        end
        
        JSON.parse(response.body)
    end
    
    def create_message(recipient_id, message, subject = nil, thread_token = nil)
        response = self.class.post(
            '/messages',
            body: {
                "sender": @email,
                "recipient_id": recipient_id,
                "token": thread_token,
                "subject": subject,
                "stripped-text": message
            },
            headers: { "authorization" => @auth_token }
        )
    end
    
    def create_submission(checkpoint_id, assignment_branch = nil, assignment_commit_link = nil, comment = nil)
        response = self.class.post(
            '/checkpoint_submissions',
            body: {
                "checkpoint_id": checkpoint_id,
                "enrollment_id": self.get_me["current_enrollment"]["id"],
                "assignment_branch": assignment_branch,
                "assignment_commit_link": assignment_commit_link,
                "comment": comment
            },
            headers: { "authorization" => @auth_token }
        )
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