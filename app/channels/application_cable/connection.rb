# app/channels/application_cable/connection.rb
module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private
    def find_verified_user
      if (verified_user = User.find_by(id: 15073))
        verified_user
      else
        reject_unauthorized_connection
      end
    end
  end
end
