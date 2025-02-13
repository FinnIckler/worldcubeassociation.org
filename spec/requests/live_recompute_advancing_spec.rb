# frozen_string_literal: true

require "rails_helper"

def ranking_condition
  AdvancementConditions::RankingCondition.new(3)
end

def percent_condition
  AdvancementConditions::PercentCondition.new(40)
end

def attempt_result_condition
  AdvancementConditions::AttemptResultCondition.new(300)
end

RSpec.describe "WCA Live API" do
  describe "Advancing Recomputation" do
    let(:competition) { FactoryBot.create(:competition, event_ids: ["333"]) }
    let(:registrations) { FactoryBot.create_list(:registration, 5, :accepted, event_ids: ["333"], competition: competition) }

    context 'with a ranking advancement condition' do
      it 'returns results with ranking better or equal to the given level' do
        round = FactoryBot.create(:round, number: 1, total_number_of_rounds: 2, event_id: "333", competition: competition, advancement_condition: ranking_condition)

        expect(round.total_accepted_registrations).to eq 5

        5.times do |i|
          FactoryBot.create(:live_result, registration: registrations[i], round: round, ranking: i + 1, average: (i + 1) * 100)
        end

        expect(round.live_results.pluck(:advancing)).to eq([true, true, true, false, false])
      end
    end

    context 'with a percent advancement condition' do
      it 'returns results with ranking better or equal to the given level' do
        round = FactoryBot.create(:round, number: 1, total_number_of_rounds: 2, event_id: "333", competition: competition, advancement_condition: percent_condition)

        expect(round.total_accepted_registrations).to eq 5

        5.times do |i|
          FactoryBot.create(:live_result, registration: registrations[i], round: round, ranking: i + 1, average: (i + 1) * 100)
        end

        # 40% of 5 is exactly 2.
        expect(round.live_results.pluck(:advancing)).to eq([true, true, false, false, false])
      end
    end

    context 'with an attempt_result advancement condition' do
      it 'returns results with ranking better or equal to the given level' do
        round = FactoryBot.create(:round, number: 1, total_number_of_rounds: 2, event_id: "333", competition: competition, advancement_condition: attempt_result_condition)

        expect(round.total_accepted_registrations).to eq 5

        5.times do |i|
          FactoryBot.create(:live_result, registration: registrations[i], round: round, ranking: i + 1, average: (i + 1) * 100)
        end

        # Only strictly _better_ than 3 seconds will proceed, so that's two entries.
        expect(round.live_results.pluck(:advancing)).to eq([true, true, false, false, false])
      end
    end
  end
end
