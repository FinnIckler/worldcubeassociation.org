# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V0::UsersController do
  describe 'GET show_user_*' do
    let!(:user) { FactoryBot.create(:user_with_wca_id, name: "Jeremy") }

    it 'can query by id' do
      get :show_user_by_id, params: { id: user.id }
      expect(response.status).to eq 200
      json = JSON.parse(response.body)
      expect(json["user"]["name"]).to eq "Jeremy"
      expect(json["user"]["wca_id"]).to eq user.wca_id
    end

    it 'can query by wca id' do
      get :show_user_by_wca_id, params: { wca_id: user.wca_id }
      expect(response.status).to eq 200
      json = JSON.parse(response.body)
      expect(json["user"]["name"]).to eq "Jeremy"
      expect(json["user"]["wca_id"]).to eq user.wca_id
    end

    it '404s nicely' do
      get :show_user_by_wca_id, params: { wca_id: "foo" }
      expect(response.status).to eq 404
      json = JSON.parse(response.body)
      expect(json["user"]).to be nil
    end

    describe 'upcoming_competitions' do
      let!(:upcoming_comp) { FactoryBot.create(:competition, :confirmed, :visible, starts: 2.weeks.from_now) }
      let!(:registration) { FactoryBot.create(:registration, :accepted, user: user, competition: upcoming_comp) }

      it 'does not render upcoming competitions by default' do
        get :show_user_by_id, params: { id: user.id }
        expect(response.status).to eq 200
        json = JSON.parse(response.body)
        expect(json.keys).not_to include "upcoming_competitions"
      end

      it 'renders upcoming competitions when upcoming_competitions param is set' do
        get :show_user_by_id, params: { id: user.id, upcoming_competitions: true }
        expect(response.status).to eq 200
        json = JSON.parse(response.body)
        expect(json["upcoming_competitions"].size).to eq 1
      end
    end
  end

  describe 'GET #me' do
    let(:person) { FactoryBot.create(:person, name: "Jeremy", wca_id: "2005FLEI01") }
    let!(:normal_user) { FactoryBot.create(:user, person: person, email: "example@email.com") }
    it 'correctly returns user' do
      sign_in { normal_user }
      get :me
      expect(response.status).to eq 200
      json = JSON.parse(response.body)
      expect(json["user"]).to eq normal_user.to_json
    end
    let!(:id_less_user) { FactoryBot.create(:user, email: "example@email.com") }
    it 'correctly returns user without wca_id' do
      get :me
      sign_in { id_less_user }
      expect(response.status).to eq 200
      json = JSON.parse(response.body)
      expect(json["user"]).to eq current_user.to_json
    end
    let(:competed_person) { FactoryBot.create(:person_who_has_competed_once, name: "Jeremy", wca_id: "2005FLEI01") }
    let!(:competed_user) { FactoryBot.create(:user, competed_person: person, email: "example@email.com") }
    it 'correctly returns user with their prs' do
      sign_in { competed_user }
      get :me
      expect(response.status).to eq 200
      json = JSON.parse(response.body)
      expect(json["user"]).to eq current_user.to_json
      expect(json["rankings"]).to eq "a"
    end
  end

  describe 'GET #permissions' do
    let(:normal_person) { FactoryBot.create(:person, name: "Jeremy", wca_id: "2005FLEI01") }
    let!(:normal_user) { FactoryBot.create(:user, person: normal_person, email: "example@email.com") }
    it 'correctly returns user a normal users permission' do
      sign_in { normal_user }
      get :permissions
      expect(response.status).to eq 200
      json = JSON.parse(response.body)
      expect(json).to eq normal_user.permissions.to_json
    end
    let(:banned_person) { FactoryBot.create(:person, name: "Ban Hammer", wca_id: "2005BANH01") }
    let!(:banned_user) { FactoryBot.create(:banned, person: banned_person, email: "example@email.com") }
    it 'correctly returns that a banned user cant compete' do
      sign_in { banned_user }
      get :permissions
      expect(response.status).to eq 200
      json = JSON.parse(response.body)
      expect(json["can_attend_competitions"]["scope"]).to eq []
    end
    it 'correctly returns a banned users end_date' do
      banned_user.teams.select(team: Team.banned).first.update_column("end_date", "2012-04-21")
      sign_in { banned_user }
      get :permissions
      expect(response.status).to eq 200
      json = JSON.parse(response.body)
      expect(json["can_attend_competitions"]["until"]).to eq "2012-04-21"
    end
    it 'correctly returns wrt to be able to create competitions' do
      sign_in { FactoryBot.create(:wrt_member, person: person, email: "example@email.com") }
      get :permissions
      expect(response.status).to eq 200
      json = JSON.parse(response.body)
      expect(json["can_create_competitions"]["scope"]).to eq "*"
    end

    it 'correctly returns delegate to be able to create competitions' do
      sign_in { FactoryBot.create(:delegate, person: person, email: "example@email.com") }
      get :permissions
      expect(response.status).to eq 200
      json = JSON.parse(response.body)
      expect(json["can_create_competitions"]["scope"]).to eq "*"
    end

    it 'correctly returns wst to be able to create competitions' do
      sign_in { FactoryBot.create(:wst_member, person: person, email: "example@email.com") }
      get :permissions
      expect(response.status).to eq 200
      json = JSON.parse(response.body)
      expect(json["can_create_competitions"]["scope"]).to eq "*"
    end

    it 'correctly returns board to be able to create competitions' do
      sign_in { FactoryBot.create(:board_member, person: person, email: "example@email.com") }
      get :permissions
      expect(response.status).to eq 200
      json = JSON.parse(response.body)
      expect(json["can_create_competitions"]["scope"]).to eq "*"
    end

    it 'correctly returns board to be able to admin competitions' do
      sign_in { FactoryBot.create(:board_member, person: person, email: "example@email.com") }
      get :permissions
      expect(response.status).to eq 200
      json = JSON.parse(response.body)
      expect(json["can_administer_competitions"]["scope"]).to eq "*"
    end

    it 'correctly returns wrt to be able to admin competitions' do
      sign_in { FactoryBot.create(:wrt_member, person: person, email: "example@email.com") }
      get :permissions
      expect(response.status).to eq 200
      json = JSON.parse(response.body)
      expect(json["can_administer_competitions"]["scope"]).to eq "*"
    end

    it 'correctly returns wst to be able to admin competitions' do
      sign_in { FactoryBot.create(:wst_member, person: person, email: "example@email.com") }
      get :permissions
      expect(response.status).to eq 200
      json = JSON.parse(response.body)
      expect(json["can_administer_competitions"]).to eq "*"
    end
    let(:delegate_person) { FactoryBot.create(:person, name: "Delegate", wca_id: "2005DELE01") }
    let!(:delegate_user) { FactoryBot.create(:delegate, person: person, email: "example@email.com") }
    it 'correctly returns delegates to be able to admin competitions they delegated' do
      delegate_user.update_column("delegated_competitions", ["TestCompetition2023"])
      sign_in { delegate_user }
      get :permissions
      expect(response.status).to eq 200
      json = JSON.parse(response.body)
      expect(json["can_administer_competitions"]).to eq ["TestCompetition2023"]
    end
    let(:organizer_person) { FactoryBot.create(:person, name: "Organizer", wca_id: "2005DELE01") }
    let!(:organizer_user) { FactoryBot.create(:user, person: person, email: "example@email.com") }
    it 'correctly returns organizer to be able to admin competitions they organize' do
      organizer_user.update_column("organized_competitions", ["TestCompetition2023"])
      sign_in { organizer_user }
      get :permissions
      expect(response.status).to eq 200
      json = JSON.parse(response.body)
      expect(json["can_administer_competitions"]).to eq ["TestCompetition2023"]
    end
  end
end
