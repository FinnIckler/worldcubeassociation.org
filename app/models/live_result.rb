# frozen_string_literal: true

class LiveResult < ApplicationRecord
  has_many :live_attempts, dependent: :destroy

  after_create :recompute_ranks
  after_update :recompute_ranks

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
      user_id: registration.user.id,
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

    def notify_users
      ActionCable.server.broadcast("results_#{round_id}", serializable_hash)
    end

  def recompute_ranks
    rank_by = round.format.sort_by == 'single' ? 'best' : 'average'
    secondary_rank_by = round.format.sort_by == 'single' ? 'average' : 'best'
    ActiveRecord::Base.connection.exec_query <<-SQL
    UPDATE live_results r
    JOIN (
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
        WHERE round_id = #{round.id}
          AND (best > 0 OR average > 0)
    ) ranked
    ON r.id = ranked.id
    SET r.ranking = ranked.rank;
  SQL

  # Set ranking to NULL for results with no valid attempts
  ActiveRecord::Base.connection.exec_query <<-SQL
    UPDATE live_results
    SET ranking = NULL
    WHERE round_id = #{round.id}
      AND (best <= 0 AND average <= 0);
  SQL
  end
end
