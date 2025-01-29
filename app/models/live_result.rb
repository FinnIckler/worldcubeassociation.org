# frozen_string_literal: true

class LiveResult < ApplicationRecord
  has_many :live_attempts, dependent: :destroy

  after_create :recompute_ranks
  after_update :recompute_ranks, :if => :should_recompute?

  after_create :recompute_advancing
  after_update :recompute_advancing, :if => :should_recompute?

  after_create :notify_users
  after_update :notify_users

  belongs_to :registration

  belongs_to :entered_by, class_name: 'User', foreign_key: 'entered_by_id'

  belongs_to :round

  def serializable_hash(options = nil)
    {
      ranking: ranking,
      attempts: live_attempts.as_json,
      registration_id: registration_id,
      round: round,
      event_id: round.event.id,
      result_id: id,
      best: best,
      average: average,
      single_record_tag: single_record_tag,
      average_record_tag: average_record_tag,
      advancing: advancing,
      advancing_questionable: advancing_questionable,
    }
  end

  private

    def should_recompute?
      best_changed? || average_changed?
    end

    def notify_users
      ActionCable.server.broadcast("results_#{round_id}", serializable_hash)
    end

    def recompute_ranks
      rank_by = round.format.sort_by == 'single' ? 'best' : 'average'
      secondary_rank_by = round.format.sort_by == 'single' ? 'average' : 'best'
      ActiveRecord::Base.connection.exec_query <<-SQL
      UPDATE live_results r
      LEFT JOIN (
          SELECT id,
                 RANK() OVER (
                     ORDER BY
                       CASE
                         WHEN #{rank_by} > 0 THEN #{rank_by}
                         ELSE 1e9
                       END ASC,
                       CASE
                         WHEN #{secondary_rank_by} > 0 THEN #{secondary_rank_by}
                         ELSE 1e9
                       END ASC
                 ) AS `rank`
          FROM live_results
          WHERE round_id = #{round.id} AND best != 0
      ) ranked
      ON r.id = ranked.id
      SET r.ranking = ranked.rank
      WHERE r.round_id = #{round.id};
    SQL
    end

    def recompute_advancing
      round_results = LiveResult.where(round: round)

      # Maximum 75% as per regulations
      max_qualifying = (round_results.length * 0.75).floor

      if round.final_round?
        round_results.where(ranking: [1,2,3]).update_all advancing: true
      else
        advancement_condition = round.advancement_condition
        if advancement_condition.is_a? AdvancementConditions::RankingCondition
          qualifying_index = advancement_condition.level > max_qualifying ?  max_qualifying : advancement_condition.level
          round_results.update_all("advancing = CASE WHEN ranking BETWEEN 1 AND #{qualifying_index} THEN TRUE ELSE FALSE END")
        end

        if advancement_condition.is_a? AdvancementConditions::PercentCondition
          amount_qualifying = (advancement_condition.level * round_results.length).floor
          qualifying_index = amount_qualifying > max_qualifying ?  max_qualifying : amount_qualifying
          round_results.update_all("advancing = CASE WHEN ranking BETWEEN 1 AND #{qualifying_index} THEN TRUE ELSE FALSE END")
        end

        if advancement_condition.is_a? AdvancementConditions::AttemptResultCondition
          sort_by = round.format.sort_by == 'single' ? 'best' : 'average'
          people_potentially_qualifying = round_results.where("#{sort_by} > ?", advancement_condition.level)
          qualifying_index = people_potentially_qualifying.length > max_qualifying ?  max_qualifying : amount_qualifying.length
          round_results.update_all("advancing = CASE WHEN id IN (SELECT id FROM round_results ORDER BY ranking ASC LIMIT #{qualifying_index}) THEN TRUE ELSE FALSE END")
        end

      end
    end
end
