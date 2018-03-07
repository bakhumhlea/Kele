module Roadmap
    def get_roadmap(id)
        response = self.class.get("/roadmaps/#{id.to_s}", headers: { "authorization" => @auth_token })
        
        JSON.parse(response.body)
    end
    
    def get_checkpoint(id)
        response = self.class.get("/checkpoints/#{id.to_s}", headers: { "authorization" => @auth_token })
        
        JSON.parse(response.body)
    end
    
    def get_enrollment_chain(id)
        response = self.class.get("/enrollment_chains/#{id.to_s}/checkpoints_remaining_in_section", headers: {"authorization" => @auth_token})
        
        JSON.parse(response.body)
    end
end