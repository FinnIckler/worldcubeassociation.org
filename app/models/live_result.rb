# frozen_string_literal: true

class LiveResult < ApplicationRecord
  has_many :live_attempts, -> { where(replaced_by_id: nil).order(:attempt_number) }

  after_create :recompute_ranks
  after_update :recompute_ranks, :if => :should_recompute?

  after_create :recompute_advancing
  after_update :recompute_advancing, :if => :should_recompute?

  after_create :compute_record_tag
  after_update :compute_record_tag, :if => :should_recompute?

  after_save :notify_users

  belongs_to :registration

  belongs_to :entered_by, class_name: 'User', foreign_key: 'entered_by_id'

  belongs_to :round

  has_one :event, through: :round

  DEFAULT_SERIALIZE_OPTIONS = {
    only: %w[ranking registration_id round live_attempts round best average single_record_tag average_record_tag advancing advancing_questionable entered_at entered_by_id],
    methods: %w[event_id attempts result_id],
    include: %w[event live_attempts round],
  }.freeze

  def serializable_hash(options = nil)
    super(DEFAULT_SERIALIZE_OPTIONS.merge(options || {}))
  end

  def result_id
    id
  end

  def event_id
    event.id
  end

  def attempts
    live_attempts.order(:attempt_number)
  end

  def potential_score
    rank_by = round.format.sort_by == 'single' ? 'best' : 'average'
    complete? ? self[rank_by.to_sym] : best_possible_score
  end

  def complete?
    live_attempts.where.not(result: 0).count == round.format.expected_solve_count
  end

  private
    def best_possible_score
      1
    end

    def should_recompute?
      best_changed? || average_changed?
    end

    def notify_users
      ActionCable.server.broadcast("results_#{round_id}", serializable_hash)
    end

    def records_by_event(records)
      records.group_by { |record| record["event_id"] }.transform_values! do |event_records|
        event_records.group_by { |record| record["type"] }.transform_values! do |type_records|
          type_records.map { |record| record["value"] }.min
        end
      end
    end

    def compute_record_tag
      # Taken from the v0 records controlled TODO: Refactor? Or probably recompute this on CAD run
      concise_results_date = ComputeAuxiliaryData.end_date || Date.current
      cache_key = ["records", concise_results_date.iso8601]
      all_records = Rails.cache.fetch(cache_key) do
        records = ActiveRecord::Base.connection.exec_query <<-SQL
        SELECT 'single' type, MIN(best) value, countryId country_id, eventId event_id
        FROM ConciseSingleResults
        GROUP BY countryId, eventId
        UNION ALL
        SELECT 'average' type, MIN(average) value, countryId country_id, eventId event_id
        FROM ConciseAverageResults
        GROUP BY countryId, eventId
      SQL
        records = records.to_a
        {
          world_records: records_by_event(records),
          continental_records: records.group_by { |record| Country.c_find(record["country_id"]).continentId }.transform_values!(&method(:records_by_event)),
          national_records: records.group_by { |record| record["country_id"] }.transform_values!(&method(:records_by_event)),
        }
      end

      record_levels = {
        WR: all_records[:world_records],
        CR: all_records[:continental_records][registration.user.country.continentId],
        NR: all_records[:national_records][registration.user.country.id]
      }

      record_levels.each do |tag, records|
        if records.dig(event_id, 'single')&.>= best
          puts(records.dig(event_id, 'single'))
          update(single_record_tag: tag.to_s)
          got_record = true
        end
        if records.dig(event_id, 'average')&.>= average
          update(average_record_tag: tag.to_s)
          got_record = true
        end
        return if got_record
      end

      personal_records = { :single => registration.best_solve(event_id, 'single'), :average => registration.best_solve(event_id, 'average')}
      if personal_records[:single].time_centiseconds < best
        update(single_record_tag: 'PR')
      end
      if personal_records[:average].time_centiseconds < average
        update(average_record_tag: 'PR')
      end
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
      round_results.update_all(advancing: false)

      missing_attempts = round.total_registrations - round_results.count
      potential_results = Array.new(missing_attempts) { |i| LiveResult.build(round: round) }
      results_with_potential = (round_results.to_a + potential_results).sort_by(&:potential_score)

      # Maximum 75% as per regulations
      max_qualifying = (round_results.length * 0.75).floor

      if round.final_round?
        round_results.update_all("advancing_questionable = ranking BETWEEN 1 AND 3")
        max_clinched = 3
      else
        advancement_condition = round.advancement_condition

        if advancement_condition.is_a? AdvancementConditions::RankingCondition
          qualifying_index = [advancement_condition.level, max_qualifying].min
          round_results.update_all("advancing_questionable = ranking BETWEEN 1 AND #{qualifying_index}")
        end

        if advancement_condition.is_a? AdvancementConditions::PercentCondition
          amount_qualifying = (advancement_condition.level * round_results.length).floor
          qualifying_index = [amount_qualifying, max_qualifying].min
          round_results.update_all("advancing_questionable = ranking BETWEEN 1 AND #{qualifying_index}")
        end

        if advancement_condition.is_a? AdvancementConditions::AttemptResultCondition
          sort_by = round.format.sort_by == 'single' ? 'best' : 'average'
          people_potentially_qualifying = round_results.where("#{sort_by} > ?", advancement_condition.level)
          qualifying_index = [people_potentially_qualifying.length, max_qualifying].min
          round_results.update_all("advancing_questionable = id IN (SELECT id FROM round_results ORDER BY ranking ASC LIMIT #{qualifying_index})")
        end

        max_clinched = qualifying_index
      end

      # Determine which results would advance if everyone achieved their best possible attempt.
      advancing_ids = results_with_potential.first(max_clinched).select(&:complete?).map(&:id)

      round_results.update_all(advancing: false)
      LiveResult.where(id: advancing_ids).update_all(advancing: true)
    end
end
